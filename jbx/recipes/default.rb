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
    notifies :reload, "service[nginx.service]", :immediate
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
  user node[:user]
  group node[:user]
  action node.attribute?(:ec2) ? "sync" : "checkout"
  notifies :create, "consul_template_config[jbx.credentials.json]", :immediate
end

consul_template_config "jbx.credentials.json" do
  templates [{
    source: "/var/www/jbx/config/credentials.json.tpl",
    destination: "/var/www/jbx/config/credentials.json",
    command: "service php#{node["php"]["version"]}-fpm reload && (cd /var/www/jbx && /bin/bash deploy.sh)",
  }]
  only_if { ::File.exist?("/var/www/jbx/config/credentials.json.tpl") }
  notifies :reload, "service[consul-template.service]", :immediate
  action :nothing
end

ruby_block "get_jbx_credentials" do
  block do
    credentials = Vault.logical.read("secret/data/#{node["environment"]}/jbx/cred")

    if (!credentials || !credentials.data[:data])
      raise "Failed to fetch credentials from vault"
    end

    File.open("/var/www/jbx/config/credentials.json", "w") do |f|
      f.write(credentials.data[:data].to_json)
    end
  end
  only_if { !File.exist?("/var/www/jbx/config/credentials.json") }
  action :run
end

if node.attribute?(:is_ci) && node["jbx"]["path"] != "/var/www/jbx"
  link "jbx.credentials.json" do
    target_file node["jbx"]["path"] + "/config/credentials.json"
    to "/var/www/jbx/config/credentials.json"
    owner node[:user]
    group node[:user]
    action :create
  end

  # Ensure DB name is overriden to match branch name
  template "#{node["jbx"]["path"]}/credentials.#{node["environment"]}.json" do
    source "credentials.env.json.erb"
    mode "0644"
  end
end

# Run the deploy script
execute "/bin/bash deploy.sh" do
  cwd node["jbx"]["path"]
  user node[:user]
  notifies :reload, "service[php#{node["php"]["version"]}-fpm.service]", :before
  subscribes :run, "git[#{node["jbx"]["git-url"]}]", :delayed
  action :nothing
end

if node.attribute?(:is_ci) && node["jbx"]["path"] != "/var/www/jbx"
  # Seed the DB
  execute "seed_dev_jb" do
    command "/usr/bin/php #{node["jbx"]["path"]}/command seed:fresh --load-dump --up --no-interaction"
    user node[:user]
    subscribes :run, "git[#{node["jbx"]["git-url"]}]", :delayed
    action :nothing
  end
end

# Run database migrations
if node.attribute?(:ec2)
  execute "database-migrations" do
    cwd "#{node["jbx"]["path"]}/application/cli"
    command "/bin/bash ./migration.sh -c migrate -d all -o --no-interaction"
    timeout 86400
    subscribes :run, "git[#{node["jbx"]["git-url"]}]", :delayed
  end
end

include_recipe cookbook_name + "::gearman"
include_recipe cookbook_name + "::crons"
include_recipe cookbook_name + "::kinesis"
