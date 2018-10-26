node.default["consul"]["config"]["server"] = true
node.default["consul"]["config"]["verify_incoming"] = true
node.default["consul"]["config"]["verify_outgoing"] = true
node.default["consul"]["config"]["bind_addr"] = node["ipaddress"]
node.default["consul"]["config"]["advertise_addr"] = node["ipaddress"]
node.default["consul"]["config"]["advertise_addr_wan"] = node["ipaddress"]

include_recipe "consul::default"

service "consul" do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action :nothing
end
