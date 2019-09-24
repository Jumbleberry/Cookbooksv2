require "vault"
include_recipe "configure::services"

if !node.attribute?(:ec2)
  include_recipe "configure::redis"
end

edit_resource(:service, "php#{node["php"]["version"]}-fpm") do
  action [:enable, :start]
end

edit_resource(:service, "redis@6379") do
  action [:enable, :start]
end

edit_resource(:service, "consul-template") do
  action [:enable, :start]
end

edit_resource(:service, "nginx") do
  action [:enable, :start]
end

openresty_site "default" do
  template "default.conf.erb"
  timing :immediately
  action :enable
end

# SSL Keys
cookbook_file "/etc/nginx/ssl/api.pem" do
  mode "0644"
  source "api.pem"
  action :create
  notifies :reload, "service[nginx]", :delayed
end

template "/etc/nginx/ssl/api.key.tpl" do
  source "cert.erb"
  mode "0644"
  variables({
    :app => "jbx",
    :domain => "api",
  })
  only_if { (certs = Vault.logical.read("secret/data/#{node["environment"]}/jbx/cert")) && !certs.data[:data][:api].nil? }
  notifies :create, "consul_template_config[api.key.json]", :immediately
end

consul_template_config "api.key.json" do
  templates [{
    source: "/etc/nginx/ssl/api.key.tpl",
    destination: "/etc/nginx/ssl/api.key",
    command: "(service nginx reload 2>/dev/null || service nginx start)",
  }]
  action :nothing
  notifies :enable, "service[consul-template]", :immediate
  notifies :start, "service[consul-template]", :immediate
  notifies :reload, "service[consul-template]", :immediate
  notifies :run, "ruby_block[wait for api.key]", :immediate
end

ruby_block "wait for api.key" do
  block do
    iter = 0
    until ::File.exists?("/etc/nginx/ssl/api.key") || iter > 15
      sleep 1
      iter += 1
    end
  end
  action :nothing
end

# Creates the api virtual host
openresty_site "api" do
  template "api.erb"
  variables ({
    hostname: node["jbx"]["domains"]["api"],
    path: "/var/www/jbx/public",
    app: "api",
  })
  timing :delayed
  action :enable
  notifies :enable, "service[nginx]", :delayed
  notifies :start, "service[nginx]", :delayed
  notifies :reload, "service[nginx]", :delayed
end
{:checkout => true, :sync => node.attribute?(:ec2)}.each do |action, should|
  git "#{node["jbx"]["git-url"]}-#{action}" do
    destination node["jbx"]["path"]
    repository node["jbx"]["git-url"]
    revision node["jbx"]["branch"]
    user node[:user]
    group node[:user]
    action action
    only_if { should }
    notifies :create, "consul_template_config[jbx.credentials.json]", :immediately
    notifies :run, "execute[/bin/bash deploy.sh]", :delayed
    if node.attribute?(:ec2)
      notifies :run, "execute[database-migrations]", :delayed
    end
  end
end
consul_template_config "jbx.credentials.json" do
  templates [{
    source: "/var/www/jbx/config/credentials.json.tpl",
    destination: "/var/www/jbx/config/credentials.json",
    command: "service php#{node["php"]["version"]}-fpm reload && (cd /var/www/jbx && /bin/bash deploy.sh)",
  }]
  only_if { ::File.exist?("/var/www/jbx/config/credentials.json.tpl") }
  notifies :enable, "service[consul-template]", :immediate
  notifies :start, "service[consul-template]", :immediate
  notifies :reload, "service[consul-template]", :immediate
end

# Run the deploy script
execute "/bin/bash deploy.sh" do
  cwd "/var/www/jbx"
  user node[:user]
  notifies :enable, "service[php#{node["php"]["version"]}-fpm]", :before
  notifies :start, "service[php#{node["php"]["version"]}-fpm]", :before
  notifies :reload, "service[php#{node["php"]["version"]}-fpm]", :before
  subscribes :run, "service[php#{node["php"]["version"]}-fpm]", :delayed
  action :nothing
  only_if do
    iter = 0
    until ::File.exists?("/var/www/jbx/config/credentials.json") || iter > 15
      sleep 1
      iter += 1
    end
    ::File.exists?("/var/www/jbx/config/credentials.json")
  end
end

if node.attribute?(:ec2)
  # Run database migrations
  execute "database-migrations" do
    cwd "#{node["jbx"]["path"]}/application/cli"
    command "php cli.php migrations:migrate --no-interaction"
    timeout 86400
    not_if { ::Dir.glob("#{node["jbx"]["path"]}/application/migrations/*.php").empty? }
    action :nothing
  end
end
