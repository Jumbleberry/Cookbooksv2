# Vault Ruby client: https://github.com/hashicorp/vault-ruby
chef_gem "vault" do
  compile_time true
end

require "vault"

# Attempt to renew an existing token
begin
  vault_token = Vault.auth_token.lookup_self()
  Vault.auth_token.renew_self()
  vault_token = vault_token.data[:id]
rescue
  vault_token = nil
end

# Create new tokens if existing token is expired, or on first launch
if node.attribute?(:ec2)
else
  if !defined?(vault_token) or vault_token.nil?
    begin
      vault_token = Vault.auth.github(::File.exist?("/home/vagrant/.github") ? IO.read("/home/vagrant/.github").strip : "")
      vault_token = vault_token.auth.client_token
    rescue
      vault_token = nil
    end
  end
end

node.force_override["etc_environment"]["VAULT_TOKEN"] = vault_token

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
