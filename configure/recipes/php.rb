# Fpm configurations
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

  if path.include? "fpm"
    node.default["php"]["xdebug"]["client_host"] = node[:container] ? "host.docker.internal" : "10.0.2.2"
    template path + "/conf.d/20-xdebug.ini" do
      manage_symlink_source true
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
      action node.attribute?(:ec2) ? :delete : :create
      notifies :reload, "service[php#{node["php"]["version"]}-fpm.service]", :delayed
    end
  end
end

file node["php"]["xdebug"]["remote_log"] do
  owner node["user"]
  group node["user"]
  mode 0744
  not_if { node["php"]["xdebug"]["remote_log"].empty? }
end

replace_or_add "php-fpm process_control_timeout" do
  path "/etc/php/#{node["php"]["version"]}/fpm/php-fpm.conf"
  pattern ".*process_control_timeout.*"
  line "process_control_timeout = #{node["php"]["fpm"]["process_control_timeout"]}"
end

template "/etc/php/#{node["php"]["version"]}/fpm/pool.d/www.conf" do
  source "www.conf.erb"
  variables(node["php"]["fpm"])
  notifies :reload, "service[php#{node["php"]["version"]}-fpm.service]", :delayed
end
