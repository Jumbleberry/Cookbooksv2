include_recipe "hashicorp-vault::gems"

install = vault_installation node["hashicorp-vault"]["version"] do |r|
  if node["hashicorp-vault"]["installation"]
    node["hashicorp-vault"]["installation"].each_pair { |k, v| r.send(k, v) }
  end
end
