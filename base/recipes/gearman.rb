apt_repository "gearman-ppa" do
  uri "ppa:ondrej/pkg-gearman"
  distribution node["lsb"]["codename"]
  components ["main"]
end

apt_update "update-gearman" do
  frequency 86400
  action :periodic
end

file "/var/log/gearmand.log" do
  mode "0644"
  owner node[:user]
  group node[:user]
  action :create
end

package "gearman" do
  action :install
  version node["gearman"]["version"]
end

# Installs gearman php package and modules
node["php"]["packages"].each do |pkg, version|
  if pkg.include? "gearman"
    package "#{pkg}" do
      action :install
      version version
    end
  end
end

service "gearman-job-server" do
  supports status: true, restart: true, reload: true, stop: true
  provider Chef::Provider::Service::Systemd
  action %i{stop disable}
end

# Un-symlink our config script to prevent install file from overwriting our good version
if node.attribute?("jbx")
  link "unlink /etc/gearman-manager/config.ini" do
    target_file "/etc/gearman-manager/config.ini"
    to "#{node["jbx"]["path"]}/application/modules/processing/config/config.ini"
    action :delete
    only_if { File.symlink?("/etc/gearman-manager/config.ini") }
  end
end

git "gearman-manager" do
  destination "/usr/share/gearman-manager"
  repository node["gearman"]["manager"]["repository"]
  revision node["gearman"]["manager"]["revision"]
  action :sync
  notifies :create, "template[gearman-manager.service]", :immediately
end

# Install gearman manager
execute "gearman-manager-install" do
  command "echo 1 | /bin/bash install.sh"
  cwd "/usr/share/gearman-manager/install"
  user "root"
  action :nothing
end

template "gearman-manager.service" do
  path "/etc/init.d/gearman-manager"
  source "gearman-manager.service.erb"
  owner "root"
  group "root"
  mode 00755
  notifies :run, "execute[gearman systemcl daemon-reload]", :immediately
end

execute "gearman systemcl daemon-reload" do
  command "systemctl daemon-reload"
  action :nothing
end

# We need to chmod gearman manager...
file "/usr/local/bin/gearman-manager" do
  action :touch
  mode "0755"
  owner "root"
  group "root"
end

service "gearman-manager" do
  supports status: true, restart: true, reload: true, stop: true
  provider Chef::Provider::Service::Systemd
  action %i{stop disable}
end

# Memcached seems to be sideloaded by gearrman; disable it
service "memcached" do
  supports status: true, restart: true, reload: true, stop: true
  action %i{stop disable}
end

# Add the cron helper libraries to the consul config folder
remote_directory "#{node["consul"]["service"]["config_dir"]}/GearmanAdmin" do
  source "GearmanAdmin"
  files_mode "0664"
  owner node["consul"]["service_user"]
  group node["consul"]["service_group"]
  mode "0775"
end

# Move the health check file
cookbook_file "gearman_check.php" do
  path "#{node["consul"]["service"]["config_dir"]}/gearman_check.php"
  owner node["consul"]["service_user"]
  group node["consul"]["service_group"]
  mode "0755"
end
