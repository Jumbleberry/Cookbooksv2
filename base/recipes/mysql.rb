# Set mysql server default password
execute "mysql-default-password" do
  command "echo \"mysql-server-5.6 mysql-server/mysql_password password #{node["mysql"]["root_password"]}\" | debconf-set-selections"
  user "root"
end
execute "mysql-default-password-again" do
  command "echo \"mysql-server-5.6 mysql-server/mysql_password_again password #{node["mysql"]["root_password"]}\" | debconf-set-selections"
  user "root"
end

package_arch = node["kernel"]["machine"] =~ /x86_64/ ? "x86_64" : "i386"
package_url = "https://downloads.mysql.com/archives/get/p/23/file/mysql-5.6.16-debian6.0-#{package_arch}.deb"
package_file = "/tmp/mysql-5.6.16.deb"

remote_file "mysql_download" do
  path package_file
  source package_url
  not_if { ::File.exist?(package_file) }
  notifies :install, "package[mysql]", :immediately
  notifies :stop, "service[mysql]", :immediately
  notifies :disable, "service[mysql]", :immediately
end

package "mysql" do
  source package_file
  provider Chef::Provider::Package::Dpkg if node["platform_family"] == "debian"
  action :nothing
end

service "mysql" do
  supports status: true, restart: true, reload: true
  action :nothing
end
