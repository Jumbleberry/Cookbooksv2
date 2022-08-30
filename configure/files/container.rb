Ohai.plugin(:Container) do
  provides "container"

  collect_data(:default) do
    if File.exist?("/.dockerenv") || !!(File.read("/proc/1/cgroup") =~ %r[^\d+:\w+:/(lxc|docker)/])
      container(true)
    end
  end
end
