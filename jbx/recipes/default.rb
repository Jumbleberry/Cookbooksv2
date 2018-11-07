include_recipe "configure::services"

if !node.attribute?(:ec2)
  include_recipe "configure::redis"
end

# SSL Keys
cookbook_file "/etc/nginx/ssl/api.jumble.dev.pem" do
  mode "0644"
  source "api.jumble.dev.pem"
  action :create
  notifies :reload, "service[nginx]", :delayed
end
template "/etc/nginx/ssl/api.jumble.dev.key.tpl" do
  source "cert.erb"
  mode "0644"
  variables({
    :app => "jbx",
    :domain => "api",
  })
  notifies :create, "consul_template_config[api.ssl.key.json]", :immediately
end
consul_template_config "api.ssl.key.json" do
  templates [{
    source: "/etc/nginx/ssl/api.jumble.dev.key.tpl",
    destination: "/etc/nginx/ssl/api.jumble.dev.key",
    command: "service nginx reload",
  }]
  action :nothing
  notifies :enable, "service[consul-template]", :immediate
  notifies :start, "service[consul-template]", :immediate
  notifies :reload, "service[consul-template]", :immediate
end

# Creates the api virtual host
openresty_site "api.jumbleberry.com" do
  template "api.jumbleberry.com.erb"
  variables ({
    hostname: "api.jumble.dev",
    path: "/var/www/jbx/public",
  })
  action :enable
  notifies :enable, "service[nginx]", :delayed
  notifies :start, "service[nginx]", :delayed
  notifies :reload, "service[nginx]", :delayed
end

{:checkout => true, :sync => node[:user] != "vagrant"}.each do |action, should|
  git "#{node["jbx"]["git-url"]}" do
    destination node["jbx"]["path"]
    repository node["jbx"]["git-url"]
    checkout_branch node["jbx"]["branch"]
    revision node["jbx"]["branch"]
    user node[:user]
    group "www-data"
    action action
    only_if { should }
    notifies :create, "consul_template_config[jbx.credentials.json]", :immediately
    notifies :run, "execute[/bin/bash deploy.sh]", :immediately
    if node.attribute?(:ec2)
      notifies :run, "execute[database-migrations]", :immediately
    end
  end
end

consul_template_config "jbx.credentials.json" do
  templates [{
    source: "/var/www/jbx/config/credentials.json.tpl",
    destination: "/var/www/jbx/config/credentials.json",
    command: "service php#{node["php"]["version"]}-fpm reload",
  }]
  action :nothing
  notifies :enable, "service[consul-template]", :immediate
  notifies :start, "service[consul-template]", :immediate
  notifies :reload, "service[consul-template]", :immediate
end

# Run the deploy script
execute "/bin/bash deploy.sh" do
  cwd "/var/www/jbx"
  user "root"
  notifies :enable, "service[php#{node["php"]["version"]}-fpm]", :delayed
  notifies :start, "service[php#{node["php"]["version"]}-fpm]", :delayed
  notifies :reload, "service[php#{node["php"]["version"]}-fpm]", :delayed
  action :nothing
end

if node.attribute?(:ec2)
  # Run database migrations
  execute "database-migrations" do
    cwd "#{node["jbx"]["core"]["path"]}/application/cli"
    command "php cli.php migrations:migrate --no-interaction"
    timeout 86400
    not_if { ::Dir.glob("#{node["jbx"]["core"]["path"]}/application/migrations/*.php").empty? }
    action :nothing
  end
end
