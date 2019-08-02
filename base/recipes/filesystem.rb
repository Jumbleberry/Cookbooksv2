# we're running on a vagrant machine - make it easier to manage /var/www/
if !node.attribute?(:ec2)

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
