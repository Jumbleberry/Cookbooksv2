# Set the default user to uid/gid 1000 if possible
edit_resource(:group, node[:user]) do
  gid node["openresty"]["group_id"]
  action :modify
end
edit_resource(:user, node[:user]) do
  uid node["openresty"]["user_id"]
  gid node["openresty"]["group_id"]
  manage_home false
  action :modify
end
