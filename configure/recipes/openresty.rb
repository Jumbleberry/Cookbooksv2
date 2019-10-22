include_recipe "openresty::commons_conf"

node["openresty"]["luarocks"]["default_rocks"].each do |rock, version|
  openresty_luarock rock do
    version version
    action :install
    notifies :reload, "service[nginx.service]", :delayed
  end
end

edit_resource(:service, "nginx.service") do
  subscribes :reload, "template[nginx.conf]", :delayed
end

edit_resource(:template, "nginx.conf") do
  source "nginx.conf.erb"
  cookbook "configure"
end
