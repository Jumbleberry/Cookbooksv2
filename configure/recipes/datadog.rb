node.default["datadog"]["tags"]["environment"] = node["environment"]
node.default["datadog"]["tags"]["service"] = (node.read("opsworks", "instance", "role") || ["dev"]).join("|")

datadog_enabled = node["configure"]["services"]["datadog"] && (node["configure"]["services"]["datadog"].include? "start")
datadog_php_ini = "/etc/php/#{node["php"]["version"]}/fpm/conf.d/98-ddtrace.ini"

replace_or_add "datadog tracing" do
  path datadog_php_ini
  pattern ".*extension = ddtrace.so.*"
  line (datadog_enabled && node["datadog"]["enable_trace_agent"] ? "" : ";") + "extension = ddtrace.so"
  notifies :restart, "service[php#{node["php"]["version"]}-fpm.service]", :delayed
  only_if { ::File.exist?(datadog_php_ini) }
end

replace_or_add "datadog profiling" do
  path datadog_php_ini
  pattern ".*zend_extension = datadog-profiling.so.*"
  line (datadog_enabled && node["datadog"]["enable_profiling"] ? "" : ";") + "zend_extension = datadog-profiling.so"
  notifies :restart, "service[php#{node["php"]["version"]}-fpm.service]", :delayed
  only_if { ::File.exist?(datadog_php_ini) }
end

if datadog_enabled
  include_recipe cookbook_name + "::vault"

  require "vault"
  ruby_block "get_datadog_api_key" do
    block do
      keys = Vault.logical.read("secret/data/#{node["environment"]}/keys")

      if (!keys || !keys.data[:data] || !keys.data[:data][:datadog])
        raise "Failed to fetch datadog credentials from vault"
      end

      node.run_state["datadog"] = { "api_key" => keys.data[:data][:datadog] }
    end
    notifies :create, "template[/etc/datadog-agent/datadog.yaml]", :immediately
  end

  include_recipe "datadog::dd-agent"

  datadog_monitor "system_core" do
    logs node["datadog"]["logs"]["system_core"] || []
    action :add
    notifies :restart, "service[datadog-agent]", :delayed
  end

  if node["configure"]["services"]["php"] && (node["configure"]["services"]["php"].include? "enable")
    datadog_monitor "php_fpm" do
      instances [{ "status_url" => "http://localhost/fpm", "ping_url" => "http://localhost/fpm-ping", "ping_reply" => "pong" }]
      logs node["datadog"]["logs"]["php"] || []
      action :add
      notifies :restart, "service[datadog-agent]", :delayed
    end
  end

  if node["configure"]["services"]["nginx"] && (node["configure"]["services"]["nginx"].include? "enable")
    datadog_monitor "nginx" do
      instances [{ "nginx_status_url" => "http://localhost/nginx" }]
      logs node["datadog"]["logs"]["nginx"] || []
      action :add
      notifies :restart, "service[datadog-agent]", :delayed
    end
  end

  if node["configure"]["services"]["gearman"] && (node["configure"]["services"]["gearman"].include? "enable")
    datadog_monitor "gearmand" do
      instances [{ "server" => node["gearman"]["host"], "port" => node["gearman"]["port"] || 4730 }]
      use_integration_template true
      logs node["datadog"]["logs"]["gearman"] || []
      action :add
      notifies :restart, "service[datadog-agent]", :delayed
    end
  end

  if node["configure"]["services"]["redis"] && (node["configure"]["services"]["redis"].include? "enable")
    datadog_monitor "redisdb" do
      instances [{ "server" => "localhost", "port" => 6379 }]
      logs node["datadog"]["logs"]["redis"] || []
      action :add
      notifies :restart, "service[datadog-agent]", :delayed
    end
  end

  if node["configure"]["services"]["mysql"] && (node["configure"]["services"]["mysql"].include? "enable")
    datadog_monitor "mysql" do
      instances [{ "server" => "localhost", "port" => 3306, "user" => "root", "pass" => node["mysql"]["root_password"] }]
      logs node["datadog"]["logs"]["mysql"] || []
      action :add
      notifies :restart, "service[datadog-agent]", :delayed
    end
  end

  if node["configure"]["services"]["postgresql"] && (node["configure"]["services"]["postgresql"].include? "enable")
    datadog_monitor "postgres" do
      instances [{ "server" => "localhost", "port" => 5432, "user" => "root", "pass" => node["pgsql"]["root_password"], "dbname" => "timescale_dev" }]
      logs node["datadog"]["logs"]["postgresql"] || []
      action :add
      notifies :restart, "service[datadog-agent]", :delayed
    end
  end
end
