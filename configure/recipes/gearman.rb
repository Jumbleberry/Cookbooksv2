edit_resource(:service, "gearman-job-server.service") do
  subscribes :restart, "template[/etc/default/gearman-job-server]", :delayed
end

edit_resource(:service, "gearman-manager.service") do
  subscribes :restart, "template[/etc/default/gearman-job-server]", :delayed
end

template "/etc/default/gearman-job-server" do
  source "gearman-job-server.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({ gearman: node["gearman"] })
end

# Add an extra reboot for vagrant instances since the filesystem may not be ready on boot
unless node.attribute?(:ec2)
  execute "service gearman-manager restart"
end
