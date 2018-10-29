template "/etc/default/gearman-job-server" do
  source "gearman-job-server.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({:gearman => node["gearman"]})
  notifies :restart, "service[gearman-job-server]", :immediately
end
