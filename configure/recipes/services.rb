edit_resource(:service, "dnsmasq.service") do
  service_name "dnsmasq"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["dnsmasq"]
end

edit_resource(:service, "php#{node["php"]["version"]}-fpm.service") do
  service_name "php#{node["php"]["version"]}-fpm"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["php"]
end

edit_resource(:service, "consul.service") do
  service_name "consul"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["consul"]
end

edit_resource(:service, "redis.service") do
  service_name "redis@6379"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["redis"]
end

edit_resource(:service, "consul-template.service") do
  service_name "consul-template"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["consul-template"]
end

edit_resource(:service, "nginx.service") do
  service_name "nginx"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["nginx"]
end
# Openresty cookbook automatically notifies "nginx", so we must keep it here
edit_resource(:service, "nginx") do
  service_name "nginx"
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "gearman-job-server.service") do
  service_name "gearman-job-server"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["gearman"]
end

edit_resource(:service, "gearman-manager.service") do
  service_name "gearman-manager"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["gearman"]
end

edit_resource(:service, "mysql.service") do
  service_name "mysql"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["mysql"]
end

edit_resource(:service, "sshd.service") do
  service_name "sshd"
  supports :status => true, :restart => true, :reload => true
  action node["configure"]["services"]["sshd"]
end
