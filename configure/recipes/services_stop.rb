node["configure"]["services"].each do |service, status|
  node.override["configure"]["services"] = %i{stop disable}
end if node["configure"]["services"]

edit_resource(:service, "dnsmasq") do
  action :nothing
end

edit_resource(:service, "php#{node["php"]["version"]}-fpm.service") do
  service_name "php#{node["php"]["version"]}-fpm"
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action :nothing
end

edit_resource(:service, "consul.service") do
  service_name "consul"
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action :nothing
end

edit_resource(:service, "redis.service") do
  service_name "redis@6379"
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action :nothing
end

edit_resource(:service, "consul-template.service") do
  service_name "consul-template"
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action :nothing
end

edit_resource(:service, "nginx.service") do
  service_name "nginx"
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action :nothing
end
# Openresty cookbook automatically notifies "nginx", so we must keep it here
edit_resource(:service, "nginx") do
  service_name "nginx"
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
end

edit_resource(:service, "gearman-job-server.service") do
  service_name "gearman-job-server"
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action :nothing
end

edit_resource(:service, "gearman-manager.service") do
  service_name "gearman-manager"
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action :nothing
end

edit_resource(:service, "mysql.service") do
  service_name "mysql"
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action :nothing
end

edit_resource(:service, "postgresql.service") do
  service_name "postgresql"
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action :nothing
end

edit_resource(:service, "datadog.service") do
  service_name "datadog-agent"
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action :nothing
end
