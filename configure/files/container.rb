Ohai.plugin(:Container) do
  depends "etc/passwd"
  provides "container"

  collect_data(:default) do
    if File.exist?("/.dockerenv") || !!(File.read("/proc/1/cgroup") =~ %r[^\d+:\w+:/(lxc|docker)/]) || etc["passwd"].key?("gitpod")
      container(true)
    end
  end
end
