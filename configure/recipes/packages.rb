node[cookbook_name]["packages"].each do |pkg|
  package pkg do
    action :install
    options "--no-install-recommends"
  end
end
