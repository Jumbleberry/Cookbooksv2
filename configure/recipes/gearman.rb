template "/etc/gearman-manager/environment" do
  source "gearman-environment.erb"
  user "gearman"
  group "gearman"
end

edit_resource(:service, "gearman-job-server.service") do
  subscribes :restart, "template[/etc/default/gearman-job-server]", :delayed if node["configure"]["services"]["gearman"].include? "start"
end

edit_resource(:service, "gearman-manager.service") do
  subscribes :restart, "git[gearman-manager]", :delayed if node["configure"]["services"]["gearman"].include? "start"
  subscribes :restart, "template[/etc/default/gearman-job-server]", :delayed if node["configure"]["services"]["gearman"].include? "start"
  subscribes :restart, "template[/etc/gearman-manager/environment]", :delayed if node["configure"]["services"]["gearman"].include? "start"
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
  service "gearman-manager" do
    supports status: true, restart: true, reload: true
    provider Chef::Provider::Service::Systemd
    action :restart
    only_if { node["configure"]["services"]["gearman"].include? "start" }
  end
end
