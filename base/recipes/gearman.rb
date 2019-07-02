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

service "gearman-job-server" do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action [:enable, :stop]
end

file "/var/log/gearmand.log" do
  mode "0644"
  owner "gearman"
  group "gearman"
  action :create_if_missing
end

git "gearman-manager" do
  destination "/usr/share/gearman-manager"
  repository node["gearman"]["manager"]["repository"]
  revision node["gearman"]["manager"]["revision"]
  action :sync
  notifies :run, "execute[gearman-manager-install]", :immediately
end

# Install gearman manager
execute "gearman-manager-install" do
  command "echo 1 | /bin/bash install.sh"
  cwd "/usr/share/gearman-manager/install"
  user "root"
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
  if node['lsb']['release'].to_f > 16
    provider Chef::Provider::Service::Systemd
  end
  supports :status => true, :restart => true, :reload => true, :stop => true
  action [:enable, :stop]
end
