include_recipe "consul-template"

edit_resource(:template, "/etc/systemd/system/consul-template.service") do
  source "consul-template.service.erb"
  cookbook "base"
  notifies :run, "execute[systemctl-daemon-reload]", :immediately
  notifies :stop, "service[consul-template]", :delayed
end

edit_resource(:service, "consul-template") do
  action %i[enable stop]
end
