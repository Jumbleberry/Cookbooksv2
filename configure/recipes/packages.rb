node[cookbook_name]["packages"].each do |pkg|
  package pkg do
    action :install
  end
end
