git "pgloader" do
  destination "/usr/local/share/pgloader"
  repository "https://github.com/dimitri/pgloader.git"
  revision "3047c9afe141763e9e7ec05b7f2a6aa97cf06801"
  depth 1
  action :checkout
  notifies :run, "execute[/usr/bin/make pgloader]", :immediately
end

execute "/usr/bin/make pgloader" do
  cwd "/usr/local/share/pgloader"
  action :nothing
end

link "/usr/local/bin/pgloader" do
  to "/usr/local/share/pgloader/build/bin/pgloader"
end
