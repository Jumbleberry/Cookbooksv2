include_recipe "configure"

require "vault"

jbx_cookbook = cookbook_name
edit_resource(:openresty_site, "default") do
  cookbook jbx_cookbook
  template "default.conf.erb"
  action :enable
  timing :delayed
end

# SSL Keys
cookbook_file "/etc/nginx/ssl/api.pem" do
  mode "0644"
  source "api.pem"
  action :create
  notifies :reload, "service[nginx.service]", :delayed
end

template "/etc/nginx/ssl/api.key.tpl" do
  source "cert.erb"
  mode "0644"
  variables({
    app: "jbx",
    domain: "api",
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
  notifies :reload, "service[consul-template.service]", :immediate
  notifies :run, "ruby_block[wait for api.key]", :immediate
end

ruby_block "wait for api.key" do
  block do
    iter = 0
    until ::File.exist?("/etc/nginx/ssl/api.key") || iter > 15
      sleep 1
      iter += 1
    end
  end
  action :nothing
end

# Create the service hosts
node["jbx"]["services"].each do |service|
  openresty_site service do
    template service + ".erb"
    variables ({
      hostname: node["jbx"]["domains"][service],
      path: "/var/www/jbx",
      app: service,
    })
    timing :delayed
    action :enable
    notifies :reload, "service[nginx.service]", :delayed
  end
end

git "#{node["jbx"]["git-url"]}" do
  destination node["jbx"]["path"]
  repository node["jbx"]["git-url"]
  revision node["jbx"]["branch"]
  user node[:user]
  group node[:user]
  action node.attribute?(:ec2) ? "sync" : "checkout"
  notifies :create, "consul_template_config[jbx.credentials.json]", :immediately
  notifies :run, "execute[/bin/bash deploy.sh]", :delayed
  notifies node.attribute?(:ec2) ? :run : :nothing, "execute[database-migrations]", :delayed
end
consul_template_config "jbx.credentials.json" do
  templates [{
    source: "/var/www/jbx/config/credentials.json.tpl",
    destination: "/var/www/jbx/config/credentials.json",
    command: "service php#{node["php"]["version"]}-fpm reload && (cd /var/www/jbx && /bin/bash deploy.sh)",
  }]
  only_if { ::File.exist?("/var/www/jbx/config/credentials.json.tpl") }
  notifies :reload, "service[consul-template.service]", :immediate
end

# Run the deploy script
execute "/bin/bash deploy.sh" do
  cwd node["jbx"]["path"]
  user node[:user]
  notifies :reload, "service[php#{node["php"]["version"]}-fpm.service]", :before
  action :nothing
end

# Run database migrations
execute "database-migrations" do
  cwd "#{node["jbx"]["path"]}/application/cli"
  command "/bin/bash ./migration.sh -c migrate -d all -o --no-interaction"
  timeout 86400
  not_if { ::Dir.glob("#{node["jbx"]["path"]}/application/migrations/*.php").empty? }
  action :nothing
end

include_recipe cookbook_name + "::gearman"
include_recipe cookbook_name + "::crons"
include_recipe cookbook_name + "::kinesis"
