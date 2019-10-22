edit_resource(:service, "consul.service") do
  subscribes :reload, "consul_config[consul]", :immediately
end
