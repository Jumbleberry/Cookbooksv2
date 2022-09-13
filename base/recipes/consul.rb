include_recipe "consul::default"

directory node["consul"]["service"]["config_dir"] do
  owner node["consul"]["service_user"]
  group node["consul"]["service_group"]
  mode "0755"
end

edit_resource(:service, "consul") do
  supports status: true, restart: true, reload: true, stop: true
  provider Chef::Provider::Service::Systemd
  action %i{stop disable}
  notifies :run, "execute[clear-consul-state]", :immediate
end

execute "clear-consul-state" do
  command "rm -rf /var/lib/consul/*"
  action :nothing
end
