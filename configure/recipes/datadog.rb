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
end

if node["php"]["fpm"]["conf_dirs"]
  datadog_monitor 'php_fpm' do
    instances node["php"]["fpm"]["conf_dirs"]
    action :add
    notifies :restart, 'service[datadog-agent]' if node['datadog']['agent_start']
  end
end