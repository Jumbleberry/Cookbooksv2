include_recipe "consul-template::service"

edit_resource(:service, "consul-template") do
  action %i[enable start]
  subscribes :restart, "template[/etc/environment]", :delayed
end
