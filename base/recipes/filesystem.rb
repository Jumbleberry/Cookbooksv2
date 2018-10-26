# we're running on a vagrant machine - make it easier to manage /var/www/
if node.attribute?(:ec2)

  # Make sure directory exists
  directory "/var/www/" do
    owner node["user"]
    group node["user"]
    recursive true
    action :create
  end

  # On vagrant, use symlinks to home
else

  # Delete dir if its not a symlink
  directory "/var/www" do
    recursive true
    action :delete
    not_if { File.symlink?("/var/www") }
  end

  # Makes sure that the www directory exists
  directory "/vagrant/www" do
    owner node["user"]
    group node["user"]
    action :create
  end

  # Symlink the folder
  link "/var/www" do
    to "/vagrant/www/"
    owner node["user"]
    group node["user"]
    action :create
    not_if { File.symlink?("/var/www") }
  end
end
