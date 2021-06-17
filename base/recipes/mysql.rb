# Set mysql server default password
execute "mysql-default-password" do
  command "echo \"mysql-server-5.6 mysql-server/mysql_password password #{node["mysql"]["root_password"]}\" | debconf-set-selections"
  user "root"
end
execute "mysql-default-password-again" do
  command "echo \"mysql-server-5.6 mysql-server/mysql_password_again password #{node["mysql"]["root_password"]}\" | debconf-set-selections"
  user "root"
end

package_arch = node["kernel"]["machine"] =~ /x86_64/ ? "amd64" : "i386"
package_url = "https://downloads.mysql.com/archives/get/p/23/file/mysql-server_5.6.51-1debian9_#{package_arch}.deb-bundle.tar"
package_file = "/tmp/mysql-5.6.51.deb"

remote_file "mysql_download" do
  path package_file + ".tar"
  source package_url
  not_if { ::File.exist?(package_file) }
  notifies :run, "execute[mysql_untar]", :immediately
  notifies :install, "package[mysql-common]", :immediately
  notifies :install, "package[mysql-community-client]", :immediately
  notifies :install, "package[mysql-client]", :immediately
  notifies :install, "package[mysql-community-server]", :immediately
  notifies :install, "package[mysql-server]", :immediately
  notifies :stop, "service[mysql]", :immediately
  notifies :disable, "service[mysql]", :immediately
end

execute "mysql_untar" do
  command "tar -xvf #{package_file}.tar"
  cwd "/tmp"
  action :nothing
end

["mysql-common", "mysql-community-client", "mysql-client", "mysql-community-server", "mysql-server"].each do |p|
  package p do
    source "/tmp/#{p}_5.6.51-1debian9_amd64.deb"
    provider Chef::Provider::Package::Dpkg if node["platform_family"] == "debian"
    action :nothing
  end
end

service "mysql" do
  supports status: true, restart: true, reload: true
  provider Chef::Provider::Service::Systemd
  action :nothing
end
