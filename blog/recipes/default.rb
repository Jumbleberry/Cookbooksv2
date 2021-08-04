include_recipe "configure"

directory node["blog"]["path"] do
  owner node[:user]
  group node[:user]
  mode "0755"
  action :create
end

execute "ghost install 3.0.2 local --process local --no-setup --no-stack --no-start --no-enable --no-prompt" do
  user node[:user]
  cwd node["blog"]["path"]
  environment ({ "HOME" => node["blog"]["path"] })
  not_if { ::File.exist?("#{node["blog"]["path"]}/current") }
end

template "#{node["blog"]["path"]}/config.production.json.tpl" do
  source "config.env.json.erb"
end

consul_template_config "blog.config.production.json" do
  templates [{
              source: "#{node["blog"]["path"]}/config.production.json.tpl",
              destination: "#{node["blog"]["path"]}/config.production.json",
              command: "service blog restart",
            }]
  notifies :reload, "service[consul-template.service]", :delayed
end

execute "consul-template blog.config.production.json" do
  sensitive true
  command lazy {
    "consul-template -once -template \"#{node["blog"]["path"]}/config.production.json.tpl:#{node["blog"]["path"]}/config.production.json\" " +
      "-vault-addr \"#{node["hashicorp-vault"]["config"]["address"]}\" -vault-token \"#{node.run_state["VAULT_TOKEN"]}\""
  }
  environment ({ "ENV" => node[:environment] })
  only_if { ::File.exist?("#{node["blog"]["path"]}/config.production.json.tpl") }
  notifies :restart, "service[blog]", :delayed if node["blog"]["enabled"]
end

git "#{node["blog"]["git-url"]}" do
  destination "#{node["blog"]["path"]}/current/content/themes/jumbleberry"
  repository node["blog"]["git-url"]
  revision node["blog"]["branch"]
  depth 1
  user node[:user]
  group node[:user]
  action :sync
  notifies :restart, "service[blog]", :delayed if node["blog"]["enabled"]
end

openresty_site "blog" do
  template "blog.erb"
  variables ({
              hostname: node["blog"]["hostname"],
              path: node["blog"]["path"],
              app: "blog",
            })
  timing :delayed
  action node["blog"]["enabled"] ? :enable : :disable
  notifies :reload, "service[nginx.service]", :delayed
end

template "/etc/systemd/system/blog.service" do
  source "blog.service.erb"
  variables ({
    path: node["blog"]["path"],
    user: node[:user],
    group: node[:user],
  })
  mode "0755"
  notifies :run, "execute[blog systemcl daemon-reload]", :immediately
end

execute "blog systemcl daemon-reload" do
  command "systemctl daemon-reload"
  action :nothing
end

service "blog" do
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action node["blog"]["enabled"] ? %i{enable start} : %i{disable stop}
end

cron "[Blog] Sync Content" do
  command "aws s3 sync #{node["blog"]["path"]}/current/content/images/ #{node["blog"]["s3"]}; aws s3 sync #{node["blog"]["s3"]} #{node["blog"]["path"]}/current/content/images/"
  minute "*"
  user node[:user]
  action node["blog"]["enabled"] ? :create : :delete
end
