if node.attribute?(:ec2)
  edit_resource(:directory, "/var/www") do
    mode 00770
  end
end

include_recipe "openresty::commons_conf"

edit_resource(:template, "nginx.conf") do
  source "nginx.conf.erb"
  cookbook "configure"
end
