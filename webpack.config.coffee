_= require "underscore"
fs= require "fs"
path= require "path"
webpack= require "webpack"
env= process.env
host  = env.npm_config_host ? "localhost"
port  = env.npm_config_port ? "8080"
env   = env.NODE_ENV        ? "development"

module.exports=
  devtool: "inline-source-map"
  entry: fs.readdirSync(path.join(__dirname, "src")).reduce (entries, dir)->
    fullDir= path.join __dirname, "src", dir
    entry= path.join fullDir, "app.coffee"
    if fs.statSync(fullDir).isDirectory() and fs.existsSync(entry)
      entries[dir]= [
        "webpack-hot-middleware/client?path=http://#{host}:#{port}/__webpack_hmr&reload=true"
        entry
      ]
    entries
  , {}
  output:
    path: path.join __dirname, "__bundled__"
    filename: "[name].js", chunkFilename: "[id].chunk.js"
  module:
    rules: _.values do ->
      Js    : test: /\.js$/, loader: "babel-loader", exclude: /node_modules/, options: presets:["env"]
      Coffee: test: /\.coffee$/, loader: "coffee-loader"
      Pug   : test: /\.pug$/, loader: "pug-loader"
      Vue   :
        test: /\.vue$/, loader: "vue-loader"

  plugins: _.flatten _.values
    Html    : do ->
      Plugin = require "html-webpack-plugin"
      fs.readdirSync(path.join(__dirname, "src")).reduce (entries, dir)->
        fullDir= path.join __dirname, "src", dir
        entry= path.join fullDir, "index.pug"
        if fs.statSync(fullDir).isDirectory() and fs.existsSync(entry)
          entries.push new Plugin
            template : entry
            filename : "#{dir}/index.html"
            inject: off, env: env, chunks: ["shared", dir]
        entries
      , []


    Chunks: new webpack.optimize.CommonsChunkPlugin
      name: 'shared', filename: 'shared.js'
    Define: new webpack.DefinePlugin
      'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development')
    Provide : new webpack.ProvidePlugin
      _: "underscore"
      Vue: "vue/dist/vue.esm.js"
      Vuex: "vuex/dist/vuex.esm.js"
    HMR: new webpack.HotModuleReplacementPlugin()
    NoEmit: new webpack.NoEmitOnErrorsPlugin()



