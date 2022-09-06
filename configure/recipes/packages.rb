node[cookbook_name]["packages"].each do |pkg|
  edit_resource(:package, pkg) do
    action :install
    options "--no-install-recommends"
    not_if "dpkg -S #{pkg}"
  end
end
