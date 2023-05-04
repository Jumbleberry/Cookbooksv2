include_recipe "datadog::dd-agent"

arch = case node["kernel"]["machine"]
  when "aarch64", "arm64" then "arm64"
  else "amd64"
  end

version = node["datadog"]["tracer"]["version"]
remote_file "datadog-php-tracer" do
  source "https://github.com/DataDog/dd-trace-php/releases/download/#{version}/datadog-php-tracer_#{version}_#{arch}.deb"
  path "/usr/local/bin/datadog-php-tracer-#{version}.deb"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

dpkg_package "datadog-php-tracer" do
  source "/usr/local/bin/datadog-php-tracer-#{version}.deb"
  action :install
end

remote_file "datadog-installer" do
  source "https://github.com/DataDog/dd-trace-php/releases/download/#{version}/datadog-setup.php"
  path "/usr/local/bin/datadog-installer-#{version}.php"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

execute "datadog-profiler" do
  command "/usr/bin/php '/usr/local/bin/datadog-installer-#{version}.php' '--enable-profiling' '--php-bin=php' '--php-bin=php#{node["php"]["version"]}' '--php-bin=php-fpm#{node["php"]["version"]}'"
  action :run
end

edit_resource(:service, "datadog-agent") do
  action %i{disable stop}
end

["process", "security", "sysprobe", "trace"].each do |service_name|
  edit_resource(:service, "datadog-agent-" + service_name) do
    action %i{disable stop}
  end
end
