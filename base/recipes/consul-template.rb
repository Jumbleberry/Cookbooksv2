include_recipe "consul-template"

edit_resource(:template, "/etc/systemd/system/consul-template.service") do
  source "consul-template.service.erb"
  cookbook "base"
  notifies :stop, "service[consul-template]", :immediate
end
