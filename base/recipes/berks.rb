execute "/opt/chef/embedded/bin/gem install nio4r:2.5.2 berkshelf:6.3.4" do
  user "root"
  not_if { ::File.exist?("/opt/chef/embedded/bin/berks") }
  notifies :create, "cookbook_file[berks]", :immediately
end

cookbook_file "berks" do
  path "/opt/chef/embedded/bin/berks"
  source "berks"
  owner "root"
  group "root"
  mode "0775"
  action :nothing
end
