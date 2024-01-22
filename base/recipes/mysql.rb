# Install mysql server
group "mysql" do
  action :create
end

user "mysql" do
  system true
  shell "/bin/false"
  home "/nonexistent"
  gid "mysql"
end

execute "mysql-configure" do
  command <<-EOH
    { \
      echo "mysql-server-5.7 mysql-server-5.7/mysql_password password '#{node["mysql"]["root_password"]}'"; \
      echo "mysql-server-5.7 mysql-server-5.7/mysql_password_again password '#{node["mysql"]["root_password"]}'"; \
      echo "mysql-server-5.7 mysql-server-5.7/data-dir select ''"; \
      echo "mysql-server-5.7 mysql-server-5.7/root-pass password '#{node["mysql"]["root_password"]}'"; \
      echo "mysql-server-5.7 mysql-server-5.7/re-root-pass password '#{node["mysql"]["root_password"]}'"; \
      echo "mysql-server-5.7 mysql-server-5.7/remove-test-db select true"; \
    } | debconf-set-selections;

    mkdir -p /var/lib/mysql /var/run/mysqld \
	    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
  EOH
  action :nothing
end

replace_or_add "mysql-dpkg-configure" do
  path "/var/lib/dpkg/status"
  pattern ".*install ok half-configured$"
  line "Status: install ok installed"
  replace_only true
  action :nothing
end

arch = case node["kernel"]["machine"]
  when "aarch64", "arm64" then "arm64"
  else "amd64"
  end

dependencies = node["lsb"]["release"].to_i >= 22 ? ["libevent-core-2.1-6", "libssl1.1_1.1.1f"] : ["libevent-core-2.1-6"]
dependencies.each do |pkg|
  execute "curl -sLO https://miscfile-staging.s3.amazonaws.com/chef/base/mysql/#{pkg}_#{arch}.deb && dpkg -i #{pkg}_#{arch}.deb" do
    cwd "/tmp"
    not_if "dpkg -S #{pkg} | grep '^#{pkg}'"
  end
end
["mysql-client-core", "mysql-client", "mysql-server-core", "mysql-server"].each do |pkg|
  package = "#{pkg}-#{node["mysql"]["version"]}_#{arch}.deb"
  execute "curl -sLO https://miscfile-staging.s3.amazonaws.com/chef/base/mysql/#{package} && (DEBIAN_FRONTEND=noninteractive dpkg -i #{package} || true)" do
    cwd "/tmp"
    not_if "dpkg -S #{pkg}- | grep '^#{pkg}-#{node["mysql"]["version"].to_i}'"
    notifies :run, "execute[mysql-configure]", :before if pkg == "mysql-server"
    notifies :edit, "replace_or_add[mysql-dpkg-configure]", :immediately if pkg == "mysql-server"
    notifies :stop, "service[mysql]", :immediately if pkg == "mysql-server"
    notifies :disable, "service[mysql]", :immediately if pkg == "mysql-server"
  end
end

file "/usr/sbin/mysqld-debug" do
  action :delete
end

bash "purge mysql utils" do
  code "rm -f $(ls -1 /usr/bin/my{isam,sql}* | grep -v -P 'mysql(d.*|import)?$')"
end

service "mysql" do
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action :nothing
end
