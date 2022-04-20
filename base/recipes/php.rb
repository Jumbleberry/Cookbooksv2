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

# Installs (non gearman) php package and modules
node["php"]["packages"].each do |pkg, version|
  unless pkg.include? "gearman"
    package "#{pkg}" do
      action :install
      version version
    end
  end
end

# Install SPX extension
bash "php-spx" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    git clone https://github.com/NoiseByNorthwest/php-spx.git
    cd php-spx
    phpize
    ./configure
    make
    sudo make install
    cd /tmp
    rm -rf /tmp/php-spx
  EOH
  not_if { ::File.exist?("/etc/php/#{node["php"]["version"]}/mods-available/spx.ini") }
  notifies :create, "template[spx.ini]", :immediately
end

template "spx.ini" do
  path "/etc/php/#{node["php"]["version"]}/mods-available/spx.ini"
  source "spx.ini.erb"
  owner "root"
  group "root"
  mode 0644
  action :nothing
end

template "/lib/systemd/system/php#{node["php"]["version"]}-fpm.service" do
  source "php-fpm.service.erb"
  notifies :run, "execute[systemctl-reload]", :immediately if node["virtualization"]["system"] != "docker"
end

execute "systemctl-reload" do
  command "/bin/systemctl --system daemon-reload"
  action :nothing
end

# Register Php service
service "php#{node["php"]["version"]}-fpm" do
  supports status: true, restart: true, reload: true, stop: true
  action %i{stop disable}
end

directory "/var/log/php/" do
  owner "www-data"
  group "www-data"
end

file "/var/log/php/error.log" do
  mode "0644"
  owner "www-data"
  group "www-data"
  action :create
end

# Install composer
remote_file "/tmp/composer-install.php" do
  source "https://getcomposer.org/installer"
  not_if { ::File.exist?("/usr/local/bin/composer") }
end

bash "install composer" do
  cwd "/tmp"
  code <<-EOL
    php composer-install.php
    mv composer.phar /usr/local/bin/composer
    chmod 0755 /usr/local/bin/composer
  EOL
  not_if { ::File.exist?("/usr/local/bin/composer") }
end
