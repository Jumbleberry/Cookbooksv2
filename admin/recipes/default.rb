include_recipe "configure"

require "vault"

# SSL Keys
cookbook_file "/etc/nginx/ssl/admin.pem" do
  mode "0644"
  source node["environment"] + "/admin.pem"
  action :create
  notifies :run, "execute[consul-template admin.key]", :immediately
  notifies :reload, "service[nginx.service]", :delayed
  ignore_failure true
end

template "/etc/nginx/ssl/admin.key.tpl" do
  source "cert.erb"
  mode "0644"
  variables({
    app: "admin",
    domain: "admin",
  })
  only_if { (certs = Vault.logical.read("secret/data/#{node["environment"]}/admin/cert")) && !certs.data[:data][:admin].nil? }
end

execute "consul-template admin.key" do
  sensitive true
  command lazy {
    "consul-template -once -template \"/etc/nginx/ssl/admin.key.tpl:/etc/nginx/ssl/admin.key\" " +
      "-vault-addr \"#{node["hashicorp-vault"]["config"]["address"]}\" -vault-token \"#{node.run_state["VAULT_TOKEN"]}\""
  }
  environment ({ "ENV" => node[:environment] })
  only_if { ::File.exist?("/etc/nginx/ssl/admin.key.tpl") }
  notifies :reload, "service[nginx.service]", :delayed
end

openresty_site "admin" do
  template "admin.erb"
  variables ({
              domain: node["admin"]["domain"],
              path: node["admin"]["path"],
              app: "admin",
            })
  timing :delayed
  action node["admin"]["enabled"] ? :enable : :disable
  notifies :reload, "service[nginx.service]", :delayed
end

# Makes sure that the directory exists
directory node["admin"]["path"] do
  owner node[:user]
  group node[:user]
  recursive true
  action :create
end

git node["admin"]["git-url"] do
  destination node["admin"]["path"]
  repository node["admin"]["git-url"]
  revision node["admin"]["branch"]
  user node[:user]
  group node[:user]
  action node.attribute?(:ec2) ? :sync : :checkout
  notifies :run, "execute[/bin/bash #{node["admin"]["path"]}/deploy.sh]", :immediately
  notifies :reload, "service[php#{node["php"]["version"]}-fpm.service]", :delayed
end

# Run the deploy script
execute "/bin/bash #{node["admin"]["path"]}/deploy.sh" do
  cwd node["admin"]["path"]
  environment ({ "COMPOSER_HOME" => "/var/www/.composer", "COMPOSER_CACHE_DIR" => "/tmp/composer" })
  user node[:user]
  action node.attribute?(:ec2) ? :nothing : :run
end

consul_template_config "admin.application.ini" do
  templates [{
              source: "#{node["admin"]["path"]}/application/configs/application.ini.tpl",
              destination: "#{node["admin"]["path"]}/application/configs/application.ini",
            }]
  action node["admin"]["consul-template"] ? :create : :delete
  only_if { ::File.exist?("#{node["admin"]["path"]}/application/configs/application.ini.tpl") }
end

execute "consul-template admin.application.ini" do
  sensitive true
  command lazy {
    "consul-template -once -template \"#{node["admin"]["path"]}/application/configs/application.ini.tpl:#{node["admin"]["path"]}/application/configs/application.ini\" " +
      "-vault-addr \"#{node["hashicorp-vault"]["config"]["address"]}\" -vault-token \"#{node.run_state["VAULT_TOKEN"]}\""
  }
  environment ({ "ENV" => node[:environment] })
  action :run
  only_if { ::File.exist?("#{node["admin"]["path"]}/application/configs/application.ini.tpl") }
end

consul_template_config "admin.settings.php" do
  templates [{
              source: "#{node["admin"]["path"]}/cron_scripts/includes/config/settings.php.tpl",
              destination: "#{node["admin"]["path"]}/cron_scripts/includes/config/settings.php",
            }]
  action node["admin"]["consul-template"] ? :create : :delete
  only_if { ::File.exist?("#{node["admin"]["path"]}/cron_scripts/includes/config/settings.php.tpl") }
end

execute "consul-template admin.settings.php" do
  sensitive true
  command lazy {
    "consul-template -once -template \"#{node["admin"]["path"]}/cron_scripts/includes/config/settings.php.tpl:#{node["admin"]["path"]}/cron_scripts/includes/config/settings.php\" " +
      "-vault-addr \"#{node["hashicorp-vault"]["config"]["address"]}\" -vault-token \"#{node.run_state["VAULT_TOKEN"]}\""
  }
  environment ({ "ENV" => node[:environment] })
  action :run
  only_if { ::File.exist?("#{node["admin"]["path"]}/cron_scripts/includes/config/settings.php.tpl") }
end

execute "consul-template sync admin" do
  command ":"
  notifies :reload, "service[consul-template.service]", :delayed
end

include_recipe cookbook_name + "::crons"
