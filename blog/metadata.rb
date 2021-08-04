name "blog"
maintainer "Jumbleberry"
maintainer_email "ian@jumbleberry"
license "All rights reserved"
description "Installs/Configures ghost"
long_description IO.read(File.join(File.dirname(__FILE__), "README.md"))
version "0.1.0"

depends "configure"
depends "hashicorp-vault"
depends "openresty"
