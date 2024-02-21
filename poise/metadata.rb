name 'poise'
maintainer 'Noah Kantrowitz'
maintainer_email 'noah@coderanger.net'
license 'Apache-2.0'
description 'Helpers for writing extensible Chef cookbooks.'

version '2.8.2'

%w(ubuntu debian centos redhat amazon scientific fedora oracle suse opensuse opensuseleap freebsd windows zlinux).each do |os|
  supports os
end

source_url 'https://github.com/chef-cookbooks/poise'
issues_url 'https://github.com/chef-cookbooks/poise/issues'
chef_version '>= 12.14'