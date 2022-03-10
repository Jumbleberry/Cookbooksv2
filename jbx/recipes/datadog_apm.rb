if node.attribute?(:ec2)
  remote_file "#{Chef::Config['file_cache_path']}/datadog-php-tracer.deb" do
    source 'https://github.com/DataDog/dd-trace-php/releases/download/0.70.1/datadog-php-tracer_0.70.1_amd64.deb'
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
  dpkg_package 'datadog-php-tracer' do
    source "#{Chef::Config['file_cache_path']}/datadog-php-tracer.deb"
    action :install
  end
end
