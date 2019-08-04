Chef::Log.level = :debug

# Vault Ruby client: https://github.com/hashicorp/vault-ruby
chef_gem "vault" do
  compile_time true
end

require "vault"

# Attempt to renew an existing token
begin
  Vault.address = node["hashicorp-vault"]["config"]["address"]
  vault_token = Vault.auth_token.lookup_self()
  Vault.auth_token.renew_self()
  vault_token = vault_token.data[:id]
rescue
  vault_token = nil
end

# Create new tokens if existing token is expired, or on first launch
if node.attribute?(:ec2)
  if !defined?(vault_token) or vault_token.nil?
    begin
      login_command = "VAULT_ADDR=\"#{node["hashicorp-vault"]["config"]["address"]}\" vault login -token-only -method=aws header_value=vault.jumbleberry.com role=#{node["environment"]}-#{node["role"]}"
      vault_token = shell_out(login_command).stdout
      Vault.token = vault_token
    rescue
      vault_token = nil
    end
  end
else
  if !defined?(vault_token) or vault_token.nil?
    begin
      home_dir = node["etc"]["passwd"][node[:user]]["dir"]
      vault_token = Vault.auth.github(::File.exist?("#{home_dir}/.github-token") ? IO.read("#{home_dir}/.github-token").strip : "")
      vault_token = vault_token.auth.client_token
    rescue
      vault_token = nil
    end
  end
end

node.force_override["etc_environment"]["VAULT_TOKEN"] = vault_token
ENV["VAULT_TOKEN"] = vault_token

edit_resource(:template, "/etc/environment") do
  source "environment.erb"
  cookbook "configure"
  mode 0664
  owner "root"
  group "root"
  variables(lazy {
    {
      :environment => node["etc_environment"],
    }
  })
end if node["etc_environment"]

edit_resource(:chef_gem, "rubyzip") do
  compile_time false
end

include_recipe "etc_environment"
