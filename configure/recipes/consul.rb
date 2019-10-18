edit_resource(:service, "consul") do
  action %i[enable start]
  subscribes :reload, "consul_config[consul]", :immediately
end
