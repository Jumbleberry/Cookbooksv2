remote_file "/tmp/nginx_upstream_check_module.zip" do
  source "https://github.com/yaoweibin/nginx_upstream_check_module/archive/master.zip"
  action :create
  notifies :run, "execute[nginx_upstream_check_module]", :immediate
end

execute "nginx_upstream_check_module" do
  command <<-EOH
    rm -rf nginx_upstream_check_module-master
    unzip nginx_upstream_check_module.zip
  EOH
  cwd "/tmp"
  action :nothing
end

cookbook_file "ngx_user.patch" do
  path "/tmp/ngx_user.patch"
  action :create
end

src_file_name = node["openresty"]["source"]["name"] % { file_prefix: node["openresty"]["source"]["file_prefix"], version: node["openresty"]["source"]["version"] }
src_file_url = node["openresty"]["source"]["url"] % { name: src_file_name }
src_filepath = "#{node["openresty"]["source"]["path"]}/#{src_file_name}.tar.gz"
nginx_path = ::File.join(
  src_file_name,
  "bundle",
  "nginx-#{node["openresty"]["source"]["version"].split(".").first(3).join(".")}"
)

bash "patch_openresty_source" do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
      tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)} &&
      cd #{nginx_path} &&
      patch -d . -p 0 < /tmp/nginx_upstream_check_module-master/check_1.11.1+.patch &&
      patch -d . -p 1 < /tmp/ngx_user.patch &&
      cd #{::File.dirname(src_filepath)} &&
      tar -czf #{::File.basename(src_file_name)}.tar.gz #{::File.basename(src_file_name)} &&
      rm -rf #{::File.basename(src_file_name)}
  EOH
end
