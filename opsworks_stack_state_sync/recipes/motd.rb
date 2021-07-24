if node.attribute?(:opsworks)
  os_release = `head -1 /etc/issue | sed -e 's/ \\\\.*//'`.chomp

  template "/etc/motd.opsworks-static" do
    source "motd.erb"
    mode "0644"
    variables({
      stack: node[:opsworks][:stack],
      layers: node[:opsworks][:layers],
      instance: node[:opsworks][:instance],
      os_release: os_release,
    })
  end
end
