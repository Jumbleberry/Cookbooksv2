include_recipe "configure"

require "vault"

jbx_cookbook = cookbook_name
edit_resource(:openresty_site, "default") do
  cookbook jbx_cookbook
  template "default.conf.erb"
  action :enable
  timing :delayed
  notifies :reload, "service[nginx.service]", :delayed
end

# SSL Keys
cookbook_file "/etc/nginx/ssl/api.pem" do
  mode "0644"
  source node["environment"] + "/api.pem"
  action :create
  notifies :run, "execute[consul-template api.key]", :immediately
  notifies :reload, "service[nginx.service]", :delayed
  ignore_failure true
end

template "/etc/nginx/ssl/api.key.tpl" do
  source "cert.erb"
  mode "0644"
  variables({
    app: "jbx",
    domain: "api",
  })
  only_if { (certs = Vault.logical.read("secret/data/#{node["environment"]}/jbx/cert")) && !certs.data[:data][:api].nil? }
  notifies :create, "consul_template_config[api.key]", :immediately
  notifies :run, "execute[consul-template api.key]", :immediately
end

consul_template_config "api.key" do
  templates [{
    source: "/etc/nginx/ssl/api.key.tpl",
    destination: "/etc/nginx/ssl/api.key",
    command: "(service nginx reload 2>/dev/null || service nginx start)",
  }]
  action :nothing
  notifies :reload, "service[consul-template.service]", :immediate
end

execute "consul-template api.key" do
  sensitive true
  command lazy {
    "consul-template -once -template \"/etc/nginx/ssl/api.key.tpl:/etc/nginx/ssl/api.key\" " +
      "-vault-addr \"#{node["hashicorp-vault"]["config"]["address"]}\" -vault-token \"#{node.run_state["VAULT_TOKEN"]}\""
  }
  environment ({ "ENV" => node[:environment] })
  action :nothing
  only_if { ::File.exist?("/etc/nginx/ssl/api.key.tpl") }
end

db_seed_status = ::File.join(node["openresty"]["source"]["state"], "jbx.dev_seed")
edit_resource(:directory, node["openresty"]["source"]["state"]) do
  owner "root"
  group "root"
  mode 00755
  action :create
  only_if { (!Chef::Config[:chef_server_url]) || (Chef::Config[:chef_server_url].include?("chefzero")) }
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

# Makes sure that the directory exists
directory node["jbx"]["path"] do
  owner node[:user]
  group node[:user]
  recursive true
  action :create
end

git "#{node["jbx"]["git-url"]}" do
  destination node["jbx"]["path"]
  repository node["jbx"]["git-url"]
  revision node["jbx"]["branch"]
  depth node["jbx"]["path"] != "/var/www/jbx" ? 1 : nil
  user node[:user]
  group node[:user]
  action node.attribute?(:ec2) ? :sync : :checkout
  notifies :run, "execute[/bin/bash #{node["jbx"]["path"]}/deploy.sh]", :immediately
end

consul_template_config "jbx.credentials.json" do
  templates [{
    source: "/var/www/jbx/config/credentials.json.tpl",
    destination: "/var/www/jbx/config/credentials.json",
    command: "service php#{node["php"]["version"]}-fpm reload && (cd /var/www/jbx && /bin/bash deploy.sh)",
  }]
  action :nothing
  only_if { ::File.exist?("/var/www/jbx/config/credentials.json.tpl") }
end

execute "consul-template jbx.credentials.json" do
  sensitive true
  command lazy {
    "consul-template -once -template \"/var/www/jbx/config/credentials.json.tpl:/var/www/jbx/config/credentials.json\" " +
      "-vault-addr \"#{node["hashicorp-vault"]["config"]["address"]}\" -vault-token \"#{node.run_state["VAULT_TOKEN"]}\""
  }
  environment ({ "ENV" => node[:environment] })
  action :nothing
  only_if { ::File.exist?("/var/www/jbx/config/credentials.json.tpl") }
end

link "jbx.credentials.json" do
  target_file node["jbx"]["path"] + "/config/credentials.json"
  to "/var/www/jbx/config/credentials.json"
  owner node[:user]
  group node[:user]
  action :nothing
  only_if { node.attribute?(:is_ci) && node["jbx"]["path"] != "/var/www/jbx" }
end

# Ensure DB name is overriden to match branch name
template "#{node["jbx"]["path"]}/config/credentials.#{node["environment"]}.json" do
  source "credentials.env.json.erb"
  mode "0644"
  action :nothing
  only_if { node.attribute?(:is_ci) && node["jbx"]["path"] != "/var/www/jbx" }
end

# Seed the DB
execute "seed_dev_jb" do
  command "/usr/bin/php #{node["jbx"]["path"]}/command seed:fresh --load-dump --up --no-interaction" + (node["jbx"]["path"] == "/var/www/jbx" ? " && touch #{db_seed_status}" : "")
  environment ({ "ENV" => node[:environment] })
  user "root"
  action :nothing
  only_if { (node.attribute?(:is_ci) && node["jbx"]["path"] != "/var/www/jbx") || (node["environment"] == "dev" && node["jbx"]["path"] == "/var/www/jbx" && !::File.exist?(db_seed_status)) }
end

# Run database migrations
execute "database-migrations" do
  cwd "#{node["jbx"]["path"]}/application/cli"
  command "/bin/bash ./migration.sh -c migrate -d all -o --no-interaction"
  timeout 86400
  action :nothing
  only_if { node.attribute?(:ec2) }
end

# Run the deploy script
execute "/bin/bash #{node["jbx"]["path"]}/deploy.sh" do
  cwd node["jbx"]["path"]
  environment ({ "COMPOSER_HOME" => "/var/www/.composer", "COMPOSER_CACHE_DIR" => "/tmp/composer" })
  user node[:user]
  notifies :create, "consul_template_config[jbx.credentials.json]", :before
  notifies :run, "execute[consul-template jbx.credentials.json]", :before
  notifies :create, "link[jbx.credentials.json]", :before
  notifies :create, "template[#{node["jbx"]["path"]}/config/credentials.#{node["environment"]}.json]", :before
  notifies :reload, "service[php#{node["php"]["version"]}-fpm.service]", :before
  notifies :run, "execute[seed_dev_jb]", :immediately
  notifies :run, "execute[database-migrations]", :immediately
  action node.attribute?(:ec2) ? :nothing : :run
end

execute "consul-template sync jbx" do
  command ":"
  notifies :reload, "service[consul-template.service]", :delayed
end

include_recipe cookbook_name + "::gearman"
include_recipe cookbook_name + "::crons"
include_recipe cookbook_name + "::kinesis"
