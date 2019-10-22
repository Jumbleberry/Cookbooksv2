stop_disable = [:stop, :disable]

edit_resource(:service, "dnsmasq.service") do
  service_name "dnsmasq"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["dnsmasq"] || stop_disable
end

edit_resource(:service, "php#{node["php"]["version"]}-fpm.service") do
  service_name "php#{node["php"]["version"]}-fpm"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["php"] || stop_disable
end

edit_resource(:service, "consul.service") do
  service_name "consul"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["consul"] || stop_disable
end

edit_resource(:service, "redis.service") do
  service_name "redis@6379"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["redis"] || stop_disable
end

edit_resource(:service, "consul-template.service") do
  service_name "consul-template"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["consul-template"] || stop_disable
end

edit_resource(:service, "nginx.service") do
  service_name "nginx"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["nginx"] || stop_disable
end
# Openresty cookbook automatically notifies "nginx", so we must keep it here
edit_resource(:service, "nginx") do
  service_name "nginx"
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "gearman-job-server.service") do
  service_name "gearman-job-server"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["gearman"] || stop_disable
end

edit_resource(:service, "gearman-manager.service") do
  service_name "gearman-manager"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["gearman"] || stop_disable
end

edit_resource(:service, "mysql.service") do
  service_name "mysql"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["mysql"] || stop_disable
end

edit_resource(:service, "sshd.service") do
  service_name "sshd"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["sshd"] || stop_disable
end
