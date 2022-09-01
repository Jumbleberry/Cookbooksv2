# Set the default user to uid/gid 1000 if possible
edit_resource(:group, node[:user]) do
  gid node["openresty"]["group_id"]
  action :modify
end
edit_resource(:user, node[:user]) do
  uid node["openresty"]["user_id"]
  gid node["openresty"]["group_id"]
  manage_home false
  action :modify
end

# we're running on a vagrant machine - make it easier to manage /var/www/
unless node.attribute?(:ec2)

  # Delete dir if its not a symlink
  directory "www-data-non-symlink" do
    path "/var/www"
    recursive true
    action :delete
    not_if { File.symlink?("/var/www") }
  end

  # Makes sure that the www directory exists
  directory "/vagrant/www" do
    owner node[:user]
    group node[:user]
    action :create
  end

  # Symlink the folder
  link "/var/www" do
    to "/vagrant/www/"
    owner node[:user]
    group node[:user]
    action :create
    not_if { File.symlink?("/var/www") }
  end
end
