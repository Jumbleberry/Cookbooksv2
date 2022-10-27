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
(node["jbx"]["certificates"].map { |k, v| v }.uniq! || []).each do |certificate|
  cookbook_file "/etc/nginx/ssl/#{certificate}.pem" do
    mode "0644"
    source node["environment"] + "/#{certificate}.pem"
    action :create
    notifies :reload, "service[nginx.service]", :delayed
    ignore_failure true
  end

  template "/etc/nginx/ssl/#{certificate}.key.tpl" do
    source "cert.erb"
    mode "0644"
    variables({
      app: "jbx",
      domain: certificate,
    })
    only_if { (certs = Vault.logical.read("secret/data/#{node["environment"]}/jbx/cert")) && !certs.data[:data][certificate.to_sym].nil? }
  end

  execute "consul-template #{certificate}.key" do
    sensitive true
    command lazy {
      "consul-template -once -template \"/etc/nginx/ssl/#{certificate}.key.tpl:/etc/nginx/ssl/#{certificate}.key\" " +
        "-vault-addr \"#{node["hashicorp-vault"]["config"]["address"]}\" -vault-token \"#{node.run_state["VAULT_TOKEN"]}\""
    }
    environment ({ "ENV" => node[:environment] })
    only_if { ::File.exist?("/etc/nginx/ssl/#{certificate}.key.tpl") }
    notifies :reload, "service[nginx.service]", :delayed
  end
end

db_seed_status = ::File.join(node["openresty"]["source"]["state"], "jbx.dev_seed")
edit_resource(:directory, node["openresty"]["source"]["state"]) do
  owner "root"
  group "root"
  mode 00755
  action :create
  only_if { (!Chef::Config[:chef_server_url]) || (Chef::Config[:chef_server_url].include?("chefzero")) }
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
end

ruby_block "jbx_version" do
  block do
    commit_hash = `su #{node[:user]} -c "cd /var/www/jbx && git rev-parse HEAD"`
    if (commit_hash && commit_hash.length)
      node.run_state[:jbx_version] = commit_hash.strip[0..7]
    end
  end
  action :run
end

# Create the service hosts
node["jbx"]["services"].each do |service|
  hostnames = node["jbx"]["domains"][service].is_a?(String) ? [node["jbx"]["domains"][service]] : node["jbx"]["domains"][service]
  certificates = hostnames.map { |hostname| [hostname, node["jbx"]["certificates"][hostname]] }.to_h

  openresty_site service do
    template service + ".erb"
    variables (lazy {
      {
        hostnames: hostnames,
        certificates: certificates,
        path: "/var/www/jbx",
        app: service,
        version: node.run_state[:jbx_version] || node[:environment],
      }
    })
    timing :delayed
    action :enable
    notifies :reload, "service[nginx.service]", :delayed
  end
end

consul_template_config "jbx.credentials.json" do
  templates [{
    source: "/var/www/jbx/config/credentials.json.tpl",
    destination: "/var/www/jbx/config/credentials.json",
    command: "cd /var/www/jbx && /bin/bash deploy.sh" + 
      (node[:environment] == "staging" ? " /bin/bash application/cli/migration.sh -c migrate -d all -o --no-interaction" : ""),
  }]
  action node["jbx"]["consul-template"] ? :create : :delete
  only_if { ::File.exist?("/var/www/jbx/config/credentials.json.tpl") }
end

execute "consul-template jbx.credentials.json" do
  sensitive true
  command lazy {
    "consul-template -once -template \"/var/www/jbx/config/credentials.json.tpl:/var/www/jbx/config/credentials.json\" " +
      "-vault-addr \"#{node["hashicorp-vault"]["config"]["address"]}\" -vault-token \"#{node.run_state["VAULT_TOKEN"]}\""
  }
  environment ({ "ENV" => node[:environment] })
  action node.attribute?(:ec2) ? :run : :nothing
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
template "#{node["jbx"]["path"]}/config/credentials.dev.json" do
  source "credentials.env.json.erb"
  mode "0644"
  action :create
  only_if { node["jbx"].attribute?(:credentials) }
end

# Seed the DB
is_throwaway = node["jbx"]["branch"] == node["jbx"]["branch"].gsub(/[^0-9A-Za-z]/, "-") && node["jbx"]["branch"].length == 40 && node["jbx"]["path"] != "/var/www/jbx"
execute "seed_dev_jb" do
  command "#{node["jbx"]["path"]}/command seed:fresh --load-dump --up --no-interaction"
  environment ({ "ENV" => node[:environment] })
  user node[:user]
  action :nothing
  notifies :run, "execute[touch #{db_seed_status}]", :immediately if node["jbx"]["path"] == "/var/www/jbx"
  only_if { (node.attribute?(:is_ci) && !is_throwaway) || (node["environment"] == "dev" && node["jbx"]["path"] == "/var/www/jbx" && !::File.exist?(db_seed_status)) }
end

execute "touch #{db_seed_status}" do
  action :nothing
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
  environment ({ "ENV" => node[:environment], "HOME" => "/var/www", "COMPOSER_HOME" => "/var/www/.composer", "COMPOSER_CACHE_DIR" => "/tmp/composer" })
  user node[:user]
  notifies :run, "execute[consul-template jbx.credentials.json]", :before
  notifies :create, "link[jbx.credentials.json]", :before
  notifies :create, "template[#{node["jbx"]["path"]}/config/credentials.dev.json]", :before
  notifies :run, "execute[seed_dev_jb]", :immediately
  notifies :run, "execute[database-migrations]", :immediately
  notifies :reload, "service[php#{node["php"]["version"]}-fpm.service]", :delayed
  action :run
end

execute "consul-template sync jbx" do
  command ":"
  notifies :reload, "service[consul-template.service]", :delayed
end

include_recipe cookbook_name + "::gearman"
include_recipe cookbook_name + "::crons"
include_recipe cookbook_name + "::kinesis"
