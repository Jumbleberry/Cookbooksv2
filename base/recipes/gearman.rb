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
