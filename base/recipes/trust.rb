include_recipe "trusted_certificate::default"

node.debug_value(cookbook_name)

# Add all trusted roots to the certificate store
for certificate in node[cookbook_name]["trusted_roots"]
  certificate_path = "#{Chef::Config[:file_cache_path]}/cookbooks/#{cookbook_name}/files/trust/#{certificate}"
  trusted_certificate certificate do
    certificate_name File.basename(certificate, File.extname(certificate))
    content File.open(certificate_path).read
    action :create
  end
end
