# Set mysql server default password
execute "mysql-default-password" do
  command "echo \"mysql-server-5.7 mysql-server/mysql_password password #{node["mysql"]["root_password"]}\" | debconf-set-selections"
  user "root"
end
execute "mysql-default-password-again" do
  command "echo \"mysql-server-5.7 mysql-server/mysql_password_again password #{node["mysql"]["root_password"]}\" | debconf-set-selections"
  user "root"
end

# Install mysql server
execute "mysql-install" do
  command "(export DEBIAN_FRONTEND=\"noninteractive\"; sudo -E apt-get install -y -q mysql-server)"
  user "root"
end

service "mysql" do
  supports status: true, restart: true, reload: true
  action %i{stop disable}
end