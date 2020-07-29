include_recipe "trusted_certificate::default"

# Add all trusted roots to the certificate store
node[cookbook_name]["trusted_roots"].each do |certificate|
  certificate_path = "#{Chef::Config[:file_cache_path]}/cookbooks/#{cookbook_name}/files/trust/#{certificate}"
  trusted_certificate certificate do
    certificate_name File.basename(certificate, File.extname(certificate))
    content File.open(certificate_path).read
    action :create
  end
end
