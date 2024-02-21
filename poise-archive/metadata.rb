name 'poise-archive'
maintainer 'Noah Kantrowitz'
maintainer_email 'noah@coderanger.net'
license 'Apache-2.0'
description 'A Chef cookbook for unpacking file archives like tar and zip.'

version '1.5.0'

%w(ubuntu debian centos redhat amazon scientific fedora oracle suse opensuse opensuseleap freebsd windows zlinux).each do |os|
  supports os
end

source_url 'https://github.com/chef-cookbooks/poise-archive'
issues_url 'https://github.com/chef-cookbooks/poise-archive/issues'
chef_version '>= 12.14'