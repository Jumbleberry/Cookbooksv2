name "security"
maintainer "Nicolai Petrov"
maintainer_email "nicolai@lyricalsecurity.com"
license "All Rights Reserved"
description "Security fixes for all Jumbleberry Applications"
version "0.1.0"
chef_version ">= 12.1" if respond_to?(:chef_version)

depends "sysctl"
depends "ohai"

