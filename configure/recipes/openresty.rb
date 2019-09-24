include_recipe "openresty::commons_conf"

node["openresty"]["luarocks"]["default_rocks"].each do |rock, version|
  openresty_luarock rock do
    version version
    action :install
  end
end

edit_resource(:template, "nginx.conf") do
  source "nginx.conf.erb"
  cookbook "configure"
end
