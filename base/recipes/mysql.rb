# Install mysql server
execute "mysql-install" do
  command <<-EOH
    { \
      echo "mysql-server-5.7 mysql-server-5.7/mysql_password password '#{node["mysql"]["root_password"]}'"; \
      echo "mysql-server-5.7 mysql-server-5.7/mysql_password_again password '#{node["mysql"]["root_password"]}'"; \
      echo "mysql-server-5.7 mysql-server-5.7/data-dir select ''"; \
      echo "mysql-server-5.7 mysql-server-5.7/root-pass password '#{node["mysql"]["root_password"]}'"; \
      echo "mysql-server-5.7 mysql-server-5.7/re-root-pass password '#{node["mysql"]["root_password"]}'"; \
      echo "mysql-server-5.7 mysql-server-5.7/remove-test-db select true"; \
    } | debconf-set-selections \
      && DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server-5.7 mysql-server;
    
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
