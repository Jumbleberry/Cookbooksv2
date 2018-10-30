include_recipe "openresty::default"

delete_resource(:template, "#{node["openresty"]["dir"]}/conf.d/http_realip.conf")
