# Fpm configurations
include_recipe cookbook_name + "::services"
node["php"]["fpm"]["conf_dirs"].each do |path|
  template path + "/php.ini" do
    source "php.ini.erb"
    variables({
      "display_errors" => node["php"]["fpm"]["display_errors"],
      "include_path" => node["php"]["fpm"]["include_path"],
    })
    if path.include? "fpm"
      notifies :reload, "service[php#{node["php"]["version"]}-fpm.service]", :delayed
    end
  end

  unless node.attribute?(:ec2)
    if path.include? "fpm"
      template path + "/conf.d/20-xdebug.ini" do
        source "xdebug.ini.erb"
        owner "root"
        group "root"
        mode 0644
        variables({ xdebug: node["php"]["xdebug"] })
        notifies :reload, "service[php#{node["php"]["version"]}-fpm.service]", :delayed
      end

      link path + "/conf.d/10-spx.ini" do
        to path + "/../mods-available/spx.ini"
        owner "root"
        group "root"
        only_if { ::File.exist? "#{path}/../mods-available/spx.ini" }
        action :create
        notifies :reload, "service[php#{node["php"]["version"]}-fpm.service]", :delayed
      end
    end
  end
end

file node["php"]["xdebug"]["remote_log"] do
  owner node["user"]
  group node["user"]
  mode 0744
  not_if { node["php"]["xdebug"]["remote_log"].empty? }
end

template "/etc/php/#{node["php"]["version"]}/fpm/pool.d/www.conf" do
  source "www.conf.erb"
  variables(node["php"]["fpm"])
  notifies :reload, "service[php#{node["php"]["version"]}-fpm.service]", :delayed
end

execute "composer self-update" do
  user "root"
end
