edit_resource(:service, "consul-template.service") do
  subscribes :restart, "template[/etc/environment]", :immediately
end
