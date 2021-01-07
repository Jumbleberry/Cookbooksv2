include_recipe "consul-template"

edit_resource(:template, "/etc/systemd/system/consul-template.service") do
  source "consul-template.service.erb"
  cookbook "base"
  notifies :run, "execute[systemctl-daemon-reload]", :immediately if node["virtualization"]["system"] != "docker"
  notifies :stop, "service[consul-template]", :immediately
end

edit_resource(:service, "consul-template") do
  action %i{stop disable}
end

edit_resource(:user, "www-data") do
  home node["openresty"]["user_home"]
  shell node["openresty"]["user_shell"]
  uid node["openresty"]["user_id"]
  gid node["openresty"]["group_id"]
  action :create
end
