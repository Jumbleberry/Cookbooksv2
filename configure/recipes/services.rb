edit_resource(:service, "dnsmasq") do
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "php#{node["php"]["version"]}-fpm") do
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "consul") do
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "redis@6379") do
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "consul-template") do
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "nginx") do
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "gearman-job-server") do
  supports :status => true, :restart => true, :reload => true
end

edit_resource(:service, "gearman-manager") do
  supports :status => true, :restart => true, :reload => true
end
