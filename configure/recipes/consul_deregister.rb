execute "consul leave" do
  notifies :stop, "service[consul.service]", :delayed
end
