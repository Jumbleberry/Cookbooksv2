execute "consul leave" do
  notifies :stop, "service[consul.service]", :delayed
end

edit_resource(:service, "consul.service") do
  service_name "consul"
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action :nothing
end
