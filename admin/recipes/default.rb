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
  notifies :create, "consul_template_config[admin.key]", :immediately
  notifies :run, "execute[consul-template admin.key]", :immediately
end

consul_template_config "admin.key" do
  templates [{
              source: "/etc/nginx/ssl/admin.key.tpl",
              destination: "/etc/nginx/ssl/admin.key",
              command: "(service nginx reload 2>/dev/null || service nginx start)",
            }]
  action :nothing
  notifies :reload, "service[consul-template.service]", :immediate
end

execute "consul-template admin.key" do
  sensitive true
  command lazy {
    "consul-template -once -template \"/etc/nginx/ssl/admin.key.tpl:/etc/nginx/ssl/admin.key\" " +
      "-vault-addr \"#{node["hashicorp-vault"]["config"]["address"]}\" -vault-token \"#{node.run_state["VAULT_TOKEN"]}\""
  }
  environment ({ "ENV" => node[:environment] })
  action :nothing
  only_if { ::File.exist?("/etc/nginx/ssl/admin.key.tpl") }
end

openresty_site "admin" do
  template "admin.erb"
  variables ({
              domain: node["admin"]["domain"],
              path: node["admin"]["path"],
              app: "admin",
            })
  timing :delayed
  action node["admin"]["enabled"] ? :enable : :disabled
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
  only_if { ::File.exist?("#{node["admin"]["path"]}/application/configs/application.ini.tpl") }
  notifies :reload, "service[consul-template.service]", :immediate
end

consul_template_config "admin.settings.php" do
  templates [{
              source: "#{node["admin"]["path"]}/cron_scripts/includes/config/settings.php.tpl",
              destination: "#{node["admin"]["path"]}/cron_scripts/includes/config/settings.php",
            }]
  only_if { ::File.exist?("#{node["admin"]["path"]}/cron_scripts/includes/config/settings.php.tpl") }
  notifies :reload, "service[consul-template.service]", :immediate
end

execute "consul-template sync admin" do
  command ":"
  notifies :reload, "service[consul-template.service]", :delayed
end

include_recipe cookbook_name + "::crons"
