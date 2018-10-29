#Fpm configurations
node["php"]["fpm"]["conf_dirs_alias"].each do |path|
  template path + "/php.ini" do
    source "php.ini.erb"
    variables({
      "display_errors" => node["php"]["fpm"]["display_errors"],
      "include_path" => node["php"]["fpm"]["include_path"],
    })
    if path.include? "fpm"
      notifies :reload, "service[php#{node["php"]["version"]}-fpm]", :delayed
    end
  end
end

template "/etc/php/#{node["php"]["version"]}/fpm/pool.d/www.conf" do
  source "www.conf.erb"
  variables(node["php"]["fpm"])
  notifies :reload, "service[php#{node["php"]["version"]}-fpm]", :delayed
end

execute "composer self-update" do
  user "root"
end
