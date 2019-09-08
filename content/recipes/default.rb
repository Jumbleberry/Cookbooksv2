include_recipe "configure"
edit_resource(:openresty_site, "default") do
  action :disable
end
