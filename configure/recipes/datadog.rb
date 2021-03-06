if node["configure"]["services"]["datadog"] && (node["configure"]["services"]["datadog"].include? "start")
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

  if node["configure"]["services"]["php"] && (node["configure"]["services"]["php"].include? "enable")
    datadog_monitor "php_fpm" do
      instances [{ "status_url" => "http://localhost/fpm", "ping_url" => "http://localhost/fpm-ping", "ping_reply" => "pong" }]
      action :add
      notifies :restart, "service[datadog-agent]", :delayed
    end
  end

  if node["configure"]["services"]["nginx"] && (node["configure"]["services"]["nginx"].include? "enable")
    datadog_monitor "nginx" do
      instances [{ "nginx_status_url" => "http://localhost/nginx" }]
      action :add
      notifies :restart, "service[datadog-agent]", :delayed
    end
  end

  if node["configure"]["services"]["gearman"] && (node["configure"]["services"]["gearman"].include? "enable")
    datadog_monitor "gearmand" do
      instances [{ "server" => node["gearman"]["host"], "port" => node["gearman"]["port"] || 4730 }]
      use_integration_template true
      action :add
      notifies :restart, "service[datadog-agent]", :delayed
    end
  end

  if node["configure"]["services"]["redis"] && (node["configure"]["services"]["redis"].include? "enable")
    datadog_monitor "redisdb" do
      instances [{ "server" => "localhost", "port" => 6379 }]
      action :add
      notifies :restart, "service[datadog-agent]", :delayed
    end
  end

  if node["configure"]["services"]["mysql"] && (node["configure"]["services"]["mysql"].include? "enable")
    datadog_monitor "mysql" do
      instances [{ "server" => "localhost", "port" => 3306, "user" => "root", "pass" => node["mysql"]["root_password"] }]
      action :add
      notifies :restart, "service[datadog-agent]", :delayed
    end
  end

  if node["configure"]["services"]["postgresql"] && (node["configure"]["services"]["postgresql"].include? "enable")
    datadog_monitor "postgres" do
      instances [{ "server" => "localhost", "port" => 5432, "user" => "root", "pass" => node["pgsql"]["root_password"], "dbname" => "local_timescale" }]
      action :add
      notifies :restart, "service[datadog-agent]", :delayed
    end
  end
end
