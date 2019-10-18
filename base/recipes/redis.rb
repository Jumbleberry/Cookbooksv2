include_recipe "redisio"

# Move the health check file
cookbook_file "redis_check.php" do
  path "#{node["consul"]["service"]["config_dir"]}/redis_check.php"
  owner node["consul"]["service_user"]
  group node["consul"]["service_group"]
  mode "0755"
end
