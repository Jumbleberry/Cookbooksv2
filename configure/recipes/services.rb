edit_resource(:service, "dnsmasq") do
  provider Chef::Provider::Service::Systemd
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "php#{node["php"]["version"]}-fpm") do
  provider Chef::Provider::Service::Systemd
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "consul") do
  provider Chef::Provider::Service::Systemd
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "redis@6379") do
  provider Chef::Provider::Service::Systemd
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "consul-template") do
  provider Chef::Provider::Service::Systemd
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "nginx") do
  provider Chef::Provider::Service::Systemd
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "gearman-job-server") do
  provider Chef::Provider::Service::Systemd
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "gearman-manager") do
  provider Chef::Provider::Service::Systemd
  supports :status => true, :restart => true, :reload => true
end
