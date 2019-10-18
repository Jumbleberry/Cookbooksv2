include_recipe "dnsmasq"

edit_resource(:service, "dnsmasq") do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action [:stop, :disable]
end
