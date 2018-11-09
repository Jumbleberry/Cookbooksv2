include_recipe "openresty::default"

delete_resource(:template, "#{node["openresty"]["dir"]}/conf.d/http_realip.conf")

edit_resource(:directory, "#{node["openresty"]["dir"]}/ssl") do
  owner node["openresty"]["user"]
  group node["openresty"]["user"]
  mode "0760"
  action :create
end
