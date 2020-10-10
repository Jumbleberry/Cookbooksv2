include_recipe "configure"

directory node["content"]["path"] do
  owner node[:user]
  group node[:user]
  mode 0700
  action :create
  recursive true
end

git node["content"]["content"]["url"] do
  repository node["content"]["content"]["url"]
  destination node["content"]["content"]["destination"]
  revision node["content"]["content"]["revision"]
  user node[:user]
  action :sync
end

git node["content"]["jumbleberry.com"]["url"] do
  repository node["content"]["jumbleberry.com"]["url"]
  destination node["content"]["jumbleberry.com"]["destination"]
  revision node["content"]["jumbleberry.com"]["revision"]
  user node[:user]
  action :sync
end

execute "cp-content" do
  command <<-EOH
    mkdir #{node["content"]["content"]["destination"]}/jumbleberry.com
    cp -R . #{node["content"]["content"]["destination"]}/jumbleberry.com
  EOH
  cwd "#{node["content"]["jumbleberry.com"]["destination"]}/src"
  user node[:user]
end

execute "minify-content" do
  command <<-EOH
    #minification of JS files
    find #{node["content"]["content"]["destination"]} -type f \
        -name "*.js" ! -name "*.min.*" \
        -exec echo {} \\; \
        -exec uglifyjs -o {}.min {} \\; \
        -exec rm {} \\; \
        -exec mv {}.min {} \\;

    #minification of CSS files
    find #{node["content"]["content"]["destination"]} -type f \
        -name "*.css" ! -name "*.min.*" \
        -exec echo {} \\; \
        -exec uglifycss --output {}.min {} \\; \
        -exec rm {} \\; \
        -exec mv {}.min {} \\;

    #minification of HTML files
    find #{node["content"]["content"]["destination"]} -type f \
        -name "*.html" \
        -exec echo {} \\; \
        -exec html-minifier --collapse-whitespace --conservativeCollapse --remove-comments --remove-optional-tags --remove-redundant-attributes --remove-script-type-attributes --remove-tag-whitespace --use-short-doctype --minify-css true --minify-js true --continueOnParseError --output {} {} \\;

    # Copy files and delete any remaining files older than 7 days
    cp -R --no-preserve=timestamps #{node["content"]["content"]["destination"]}/* #{node["content"]["path"]}
    chown -R #{node["user"]}:#{node["user"]} #{node["content"]["path"]}
    find #{node["content"]["path"]} -type f -mtime +7 -exec rm {} \\;
    rm -rf #{node["content"]["content"]["destination"]}
    rm -rf #{node["content"]["jumbleberry.com"]["destination"]}
  EOH
  cwd "/tmp"
  notifies :reload, "service[nginx.service]", :delayed
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
end
