template "/etc/gearman-manager/environment" do
  source "gearman-environment.erb"
  user "gearman"
  group "gearman"
end

gearman_started = (node["configure"]["services"]["gearman"] || {}).include? "start"

edit_resource(:service, "gearman-job-server.service") do
  subscribes :restart, "template[/etc/default/gearman-job-server]", :delayed if gearman_started
end

edit_resource(:service, "gearman-manager.service") do
  subscribes :restart, "git[gearman-manager]", :delayed if gearman_started
  subscribes :restart, "template[/etc/default/gearman-job-server]", :delayed if gearman_started
  subscribes :restart, "template[/etc/gearman-manager/environment]", :delayed if gearman_started
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
    only_if { gearman_started }
  end
end
