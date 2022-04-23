include_recipe "datadog::dd-agent"

cookbook_file "datadog-setup.php" do
  path "/usr/local/bin/datadog-setup.php"
  owner "root"
  group "root"
  mode "0755"
  action :create
  notifies :run, "execute[datadog-profiler]", :immediately
end

execute "datadog-profiler" do
  command "/usr/bin/php '/usr/local/bin/datadog-setup.php' '--enable-profiling' '--php-bin=php' '--php-bin=php#{node["php"]["version"]}' '--php-bin=php-fpm#{node["php"]["version"]}'"
  action :nothing
end

edit_resource(:service, "datadog-agent") do
  action %i{disable stop}
end

["process", "security", "sysprobe", "trace"].each do |service_name|
  edit_resource(:service, "datadog-agent-" + service_name) do
    action %i{disable stop}
  end
end
