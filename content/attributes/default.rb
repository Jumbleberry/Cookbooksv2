default["openresty"]["luarocks"]["default_rocks"] = {
  "jumbleberry-auto-ssl" => "0.13.1-2",
}

default["nodejs"]["npm_packages"] += [
  {
    "name" => "uglify-js",
    "options" => ["--prefix /usr"],
  },
  {
    "name" => "uglifycss",
    "options" => ["--prefix /usr"],
  },
  {
    "name" => "html-minifier",
    "options" => ["--prefix /usr"],
  },
]

default["content"] = {
  "content" => {
    "url" => "git@github.com:Jumbleberry/Content.git",
    "destination" => "/tmp/content",
    "revision" => "master",
  },
  "jumbleberry.com" => {
    "url" => "git@github.com:Jumbleberry/Jumbleberry.com.git",
    "destination" => "/tmp/jumbleberry",
    "revision" => "v2",
  },
  "path" => "/var/www/content/",
}
