default["openresty"]["luarocks"]["default_rocks"] = {
  "lua-resty-auto-ssl" => "0.13.1",
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
