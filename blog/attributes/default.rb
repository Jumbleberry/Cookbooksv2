default["nodejs"]["version"] = "12.13.0"
default["nodejs"]["npm_packages"] = [
  {
    "name" => "ghost",
    "options" => ["--prefix /usr"],
  },
  {
    "name" => "ghost-cli",
    "options" => ["--prefix /usr"],
  },
]

# Ghost CLI won't let it be installed in a dir without public read
default["blog"]["path"] = etc["passwd"].key?("vagrant") ? "/usr/local/share/blog" : "/var/www/blog"
default["blog"]["git-url"] = "git@github.com:Jumbleberry/BlogTheme.git"
default["blog"]["branch"] = "master"
default["blog"]["hostname"] = "blog.jumbleberry.com"
default["blog"]["s3"] = "s3://jb-assets/blog.jumbleberry.com/images/"
default["blog"]["enabled"] = true
default["blog"]["consul-template"] = true
