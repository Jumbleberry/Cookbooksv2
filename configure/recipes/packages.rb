node[cookbook_name]["packages"].each do |pkg|
  package pkg do
    action :install
    options "--no-install-recommends"
    not_if "dpkg -S #{pkg} | grep '/#{pkg}$'"
  end
end
