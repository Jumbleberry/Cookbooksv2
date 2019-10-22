require "vault"
Vault.address = node["hashicorp-vault"]["config"]["address"]

# Attempt to renew an existing token
ruby_block "renew_vault_token" do
  block do
    begin
      Vault.address = node["hashicorp-vault"]["config"]["address"]
      vault_token = Vault.auth_token.lookup_self()
      Vault.auth_token.renew_self()
      node.run_state["VAULT_TOKEN"] = vault_token.data[:id]
    rescue
      node.run_state["VAULT_TOKEN"] = nil
    end
  end
end

# Create new tokens if existing token is expired, or on first launch
ruby_block "get_vault_token" do
  block do
    if node.attribute?(:ec2)
      if !defined?(node.run_state["VAULT_TOKEN"]) or node.run_state["VAULT_TOKEN"].nil?
        begin
          login_command = "VAULT_ADDR=\"#{node["hashicorp-vault"]["config"]["address"]}\" vault login -token-only -method=aws header_value=vault.jumbleberry.com role=#{node["environment"]}-#{node["role"]}"
          node.run_state["VAULT_TOKEN"] = shell_out(login_command).stdout
          Vault.token = node.run_state["VAULT_TOKEN"]
          Vault.auth_token.lookup_self()
        rescue
          node.run_state["VAULT_TOKEN"] = nil
        end
      end
    else
      if !defined?(node.run_state["VAULT_TOKEN"]) or node.run_state["VAULT_TOKEN"].nil?
        begin
          vault_token = Vault.auth.github(node["etc_environment"]["GITHUB"])
          node.run_state["VAULT_TOKEN"] = vault_token.auth.client_token
        rescue
          node.run_state["VAULT_TOKEN"] = nil
        end
      end
    end
  end
end

edit_resource(:chef_gem, "rubyzip") do
  compile_time false
end

include_recipe "etc_environment"

edit_resource(:template, "/etc/environment") do
  source "environment.erb"
  mode 0664
  owner "root"
  group "root"
  variables(lazy {
    {
      :environment => node["etc_environment"].merge(
        {:VAULT_TOKEN => node.run_state["VAULT_TOKEN"]}
      ),
    }
  })
end
