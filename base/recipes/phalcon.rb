# Install Zephir Parser
execute "zephir-lang" do
  command <<-EOH
    sudo apt-get install php#{node["php"]["version"]}-dev re2c -yq --no-install-recommends \
      && git clone --branch master https://github.com/zephir-lang/php-zephir-parser.git zephir-parser \
      && cd zephir-parser \
      && phpize \
      && ./configure \
      && make \
      && sudo make install
  EOH
  cwd "/usr/local"
  not_if { ::File.exist?("/etc/php/#{node["php"]["version"]}/mods-available/zephir.ini") }
  notifies :create, "template[zephir.ini]", :immediately
end

template "zephir.ini" do
  path "/etc/php/#{node["php"]["version"]}/mods-available/zephir.ini"
  source "zephir.ini.erb"
  owner "root"
  group "root"
  mode 0644
  action :nothing
  notifies :create, "link[/etc/php/#{node["php"]["version"]}/cli/conf.d/10-zephir.ini]", :immediately
end

link "/etc/php/#{node["php"]["version"]}/cli/conf.d/10-zephir.ini" do
  to "/etc/php/#{node["php"]["version"]}/mods-available/zephir.ini"
  action :nothing
end

# Add Zephir Phar
remote_file "zephir.phar" do
  path "/usr/local/bin/zephir"
  source "https://miscfile-staging.s3.amazonaws.com/chef/base/zephir.phar"
  mode "0755"
end

# Install Phalcon
phalcon_branch = node["php"]["version"].to_i >= 8 ? "3.4.x_php8" : "3.4.x"
execute "phalcon" do
  command <<-EOH
    git clone --depth 1 --branch #{phalcon_branch} https://github.com/Jumbleberry/Phalcon.git cphalcon \
      && cd cphalcon \
      && /usr/local/bin/zephir fullclean \
      && ZEPHIR_RELEASE=1 CFLAGS="-march=native -O3 -fvisibility=hidden -fomit-frame-pointer -flto -DPHALCON_RELEASE -DZEPHIR_RELEASE=1" /usr/local/bin/zephir build --no-dev \
      && cd .. \
      && rm -rf cphalcon
  EOH
  cwd "/usr/local"
  not_if { ::File.exist?("/etc/php/#{node["php"]["version"]}/mods-available/phalcon.ini") }
  notifies :create, "template[phalcon.ini]", :immediately
end

template "phalcon.ini" do
  path "/etc/php/#{node["php"]["version"]}/mods-available/phalcon.ini"
  source "phalcon.ini.erb"
  owner "root"
  group "root"
  mode 0644
  action :nothing
end

node["php"]["fpm"]["conf_dirs"].each do |path|
  link path + "/conf.d/50-phalcon.ini" do
    to path + "/../mods-available/phalcon.ini"
    only_if { ::File.exist? "#{path}/../mods-available/phalcon.ini" }
    action :create
  end
end

unless node.attribute?(:ec2)
  git "phalcon-devtools" do
    repository node["phalcon"]["devtools"]
    user "root"
    branch "3.4.x"
    destination "/usr/share/phalcon-devtools"
    action :sync
  end

  bash "phalcon-devtools" do
    user "root"
    cwd "/usr/share/phalcon-devtools"
    code <<-EOH
      ./phalcon.sh
    EOH
    not_if do
      ::File.exist?("/usr/bin/phalcon")
    end
    notifies :create, "link[/usr/bin/phalcon]", :immediately
  end

  link "/usr/bin/phalcon" do
    to "/usr/share/phalcon-devtools/phalcon"
    action :nothing
  end
end
