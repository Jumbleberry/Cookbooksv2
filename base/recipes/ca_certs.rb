execute "update_chef_certificates" do
  command "cp /etc/ssl/certs/ca-certificates.crt /opt/chef/embedded/ssl/certs/cacert.pem"
end
