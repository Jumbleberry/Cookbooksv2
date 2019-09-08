default["openresty"]["luarocks"]["default_rocks"] = {
  "lua-resty-auto-ssl" => "0.12.0-1",
}

default["nodejs"]["npm_packages"] = [
  {
    "name" => "uglify-js",
  },
  {
    "name" => "uglifycss",
  },
  {
    "name" => "html-minifier",
  },
]

default["content"] = {
  "git" => {
    "url" => "git@github.com:Jumbleberry/Content.git",
    "destination" => "/tmp/content",
    "revision" => "master",
  },
  "path" => "/var/www/content/",
}
