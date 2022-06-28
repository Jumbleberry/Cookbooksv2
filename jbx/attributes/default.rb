default["openresty"]["default_site_enabled"] = true
default["jbx"]["consul-template"] = false

certificates = {}
node["jbx"]["domains"].each do |key, domains|
  domains = domains.is_a?(String) ? [domains] : domains
  domains.each do |domain|
    certificates[domain] = domain.split(".").slice(-2, 2).join(".")
  end
end

default["jbx"]["certificates"] = certificates
