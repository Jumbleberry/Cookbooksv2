node[cookbook_name]["ppas"].each_with_index do |ppa, index|
  unless node[:container]
    execute "core-ppa-#{index + 1}" do
      command "add-apt-repository #{ppa}"      
    end
  else
    apt_repository "core-ppa-#{index + 1}" do
      uri ppa
      retries 5
    end
  end
end

node[cookbook_name]["packages"].each do |pkg|
  package pkg do
    action :install
    options "--no-install-recommends"
    not_if "dpkg -S #{pkg} | grep '/\b#{pkg}$'"
  end
end

execute "python-pip" do
  command "python3.8 -m pip install -U pip"
  only_if { node[cookbook_name]["packages"].include? "python3.8" }
end