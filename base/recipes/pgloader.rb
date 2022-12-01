git "pgloader" do
  destination "/usr/local/share/pgloader"
  repository "https://github.com/dimitri/pgloader.git"
  revision "759777ae0818e9c198ff4dda016546193ce33f81"
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
