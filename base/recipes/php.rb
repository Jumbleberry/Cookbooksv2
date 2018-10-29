# Custom repositories
apt_repository "php-ppa" do
  uri "ppa:ondrej/php"
  distribution node["lsb"]["codename"]
  components ["main"]
end

apt_update "update-php" do
  frequency 86400
  action :periodic
end

# Installs php package and modules
node["php"]["packages"].each do |pkg, version|
  package "#{pkg}" do
    action :install
    version version
  end
end

#Register Php service
service "php#{node["php"]["version"]}-fpm" do
  supports :status => true, :restart => true, :reload => true, :stop => true
  action [:enable, :stop]
end

directory "/var/log/php/" do
  owner "www-data"
  group "www-data"
end

file "/var/log/php/error.log" do
  mode "0644"
  owner "www-data"
  group "www-data"
  action :create_if_missing
end

#Install composer
remote_file "/tmp/composer-install.php" do
  source "https://getcomposer.org/installer"
  not_if { ::File.exists?("/usr/local/bin/composer") }
end

bash "install composer" do
  cwd "/tmp"
  code <<-EOL
    php composer-install.php
    mv composer.phar /usr/local/bin/composer
    chmod 0755 /usr/local/bin/composer
  EOL
  not_if { ::File.exists?("/usr/local/bin/composer") }
end
