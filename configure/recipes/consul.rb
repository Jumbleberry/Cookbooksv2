consul_config node["consul"]["service_name"] do |r|
  node["consul"]["config"].each_pair { |k, v| r.send(k, v) }
end

# If we reload consul to quickly after it starts, it crashes
# As a result we'll only trigger a reload if it was already running
execute "consul-reload-check" do
  command "true"
  only_if "systemctl is-active --quiet " + node["consul"]["service_name"]
  notifies :reload, "service[consul.service]", :delayed
end
