include_recipe "consul-template"

edit_resource(:template, "/etc/systemd/system/consul-template.service") do
  source "consul-template.service.erb"
  cookbook "base"
  notifies :run, "execute[systemctl-daemon-reload]", :immediately unless node[:container]
  notifies :stop, "service[consul-template]", :immediately
end

edit_resource(:service, "consul-template") do
  provider Chef::Provider::Service::Systemd
  action %i{stop disable}
end

# consul-template cookbook will try and create this user
# this is needed to prevent it from mangling it
edit_resource(:user, "www-data") do
  home node["openresty"]["user_home"]
  shell node["openresty"]["user_shell"]
  uid node["openresty"]["user_id"]
  gid node["openresty"]["group_id"]
  action :create
end
