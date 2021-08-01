apt_repository "gearman-ppa" do
  uri "ppa:ondrej/pkg-gearman"
  distribution node["lsb"]["codename"]
  components ["main"]
end

apt_update "update-gearman" do
  frequency 86400
  action :periodic
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

manager_dir = "/usr/local/share/gearman-manager"
directory manager_dir do
  owner node[:user]
  group node[:user]
  action :create
end

directory "/etc/gearman-manager/workers" do
  owner node[:user]
  group node[:user]
  recursive true
  action :create
end

directory "/run/gearman-manager" do
  owner node[:user]
  group node[:user]
  action :create
end

git "gearman-manager" do
  destination manager_dir
  repository node["gearman"]["manager"]["repository"]
  revision node["gearman"]["manager"]["revision"]
  user node[:user]
  group node[:user]
  action :sync
end

link "/usr/local/bin/gearman-manager" do
  to "#{manager_dir}/pecl-manager.php"
  mode "0755"
  action :create
end

template "gearman-manager.service" do
  path "/etc/init.d/gearman-manager"
  source "gearman-manager.service.erb"
  owner "root"
  group "root"
  mode "0755"
  notifies :run, "execute[gearman systemcl daemon-reload]", :immediately
end

execute "gearman systemcl daemon-reload" do
  command "systemctl daemon-reload"
  action :nothing
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
