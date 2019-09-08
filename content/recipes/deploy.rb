include_recipe "configure::services"
edit_resource(:service, "nginx") do
  action [:enable, :start]
end

directory node["content"]["path"] do
  owner node[:user]
  group node[:user]
  mode 0700
  action :create
  recursive true
end

{:checkout => true, :sync => true}.each do |action, should|
  git node["content"]["git"]["url"] do
    repository node["content"]["git"]["url"]
    destination node["content"]["git"]["destination"]
    revision node["content"]["git"]["revision"]
    user node[:user]
    action action
    notifies :run, "execute[minify]", :delayed
    notifies :reload, "service[nginx]", :delayed
    only_if { should }
  end
end

execute "minify" do
  command <<-EOH
    #minification of JS files
    find #{node["content"]["git"]["destination"]} -type f \
        -name "*.js" ! -name "*.min.*" \
        -exec echo {} \\; \
        -exec uglifyjs -o {}.min {} \\; \
        -exec rm {} \\; \
        -exec mv {}.min {} \\;
    
    #minification of CSS files
    find #{node["content"]["git"]["destination"]} -type f \
        -name "*.css" ! -name "*.min.*" \
        -exec echo {} \\; \
        -exec uglifycss --output {}.min {} \\; \
        -exec rm {} \\; \
        -exec mv {}.min {} \\;
    
    #minification of HTML files
    find #{node["content"]["git"]["destination"]} -type f \
        -name "*.html" \
        -exec echo {} \\; \
        -exec html-minifier --collapse-whitespace --conservativeCollapse --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype --minify-css true --minify-js true --continueOnParseError --output {} {} \\;
    
    # Copy files and delete any remaining files older than 7 days
    cp -R --no-preserve=timestamps #{node["content"]["git"]["destination"]}/* #{node["content"]["path"]}
    chown -R #{node["user"]}:#{node["user"]} #{node["content"]["path"]}
    find #{node["content"]["path"]} -type f -mtime +7 -exec rm {} \\;
    rm -rf #{node["content"]["git"]["destination"]}
  EOH
  cwd "/tmp"
  action :nothing
end

directory "#{node["openresty"]["dir"]}/ssl" do
  owner node[:user]
  group node[:user]
  recursive true
end
cookbook_file "#{node["openresty"]["dir"]}/ssl/content.crt" do
  source "content.crt"
  owner node[:user]
  group node[:user]
  mode "0600"
  action :create
end
cookbook_file "#{node["openresty"]["dir"]}/ssl/content.key" do
  source "content.key"
  owner node[:user]
  group node[:user]
  mode "0600"
  action :create
end

openresty_site "content" do
  template "content.conf.erb"
  timing :delayed
  action :enable
  notifies :reload, "service[nginx]", :delayed
end
