include_recipe "openresty::commons_conf"

edit_resource(:template, "nginx.conf") do
  source "nginx.conf.erb"
  cookbook "configure"
end

openresty_site "default" do
  template "default.conf.erb"
  timing :immediate
  action :enable
end
