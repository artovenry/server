Express= require "express"

env= process.env
host  = env.npm_config_host ? "localhost"
port  = env.npm_config_port ? "8080"
env   = env.NODE_ENV        ? "development"
app= Express()
compiler= (require "webpack")(require "./webpack.config.coffee")

app
  .use (require "webpack-dev-middleware") compiler,
    stats: colors: yes, chunks: no
  .use (require "webpack-hot-middleware") compiler
  .use Express.static __dirname

  module.exports= app.listen port, host, ->
    console.log "Server listening on http://#{host}:#{port}, Ctrl+C to stop"