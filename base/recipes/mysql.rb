arch = case node['kernel']['machine']
when 'aarch64', 'arm64' then 'arm64'
else 'amd64'
end

apt_repository "mysql-ppa" do
  uri "http://ports.ubuntu.com/ubuntu-ports"
  distribution "focal"
  components ["main", "restricted"]
  only_if  { '#{arch}' == "arm64" }
end

package "mysql-server-8.0" do
  action :remove
end

execute "mysql-install" do
  command <<-EOH
  { \
    echo "mysql-server-8.0 mysql-server-8.0/mysql_password password '#{node["mysql"]["root_password"]}'"; \
    echo "mysql-server-8.0 mysql-server-8.0/mysql_password_again password '#{node["mysql"]["root_password"]}'"; \
    echo "mysql-server-8.0 mysql-server-8.0/data-dir select ''"; \
    echo "mysql-server-8.0 mysql-server-8.0/root-pass password '#{node["mysql"]["root_password"]}'"; \
    echo "mysql-server-8.0 mysql-server-8.0/re-root-pass password '#{node["mysql"]["root_password"]}'"; \
    echo "mysql-server-8.0 mysql-server-8.0/remove-test-db select true"; \
  } | debconf-set-selections \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq apt-utils mysql-server-8.0 mysql-server;
  mkdir -p /var/lib/mysql /var/run/mysqld \
  && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
  EOH
  ignore_failure true
  notifies :edit, "replace_or_add[mysql-dpkg-configure]", :immediately
  notifies :stop, "service[mysql]", :immediately unless node[:container]
  notifies :disable, "service[mysql]", :immediately unless node[:container]
end

replace_or_add "mysql-dpkg-configure" do
  path "/var/lib/dpkg/status"
  pattern ".*install ok half-configured$"
  line "Status: install ok installed"
  replace_only true
  action :nothing
end

file "/usr/sbin/mysqld-debug" do
  action :delete
end

bash "purge mysql" do
  code "rm -f $(ls -1 /usr/bin/my{isam,sql}* | grep -v -P 'mysql(d.*|import)?$')"
end

service "mysql" do
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action :nothing
end

# apt_repository "mysql-ppa" do
#   uri "http://ports.ubuntu.com/ubuntu-ports"
#   distribution "focal"
#   components ["main", "restricted"]
#   action :remove
# end
