include_recipe "consul::default"

directory node["consul"]["service"]["config_dir"] do
  owner node["consul"]["service_user"]
  group node["consul"]["service_group"]
  mode "0755"
end

edit_resource(:service, "consul") do
  supports status: true, restart: true, reload: true, stop: true
  action %i{stop disable}
end
