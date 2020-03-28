const path = require("path");

const HtmlWebpackPlugin = require("html-webpack-plugin");
const VueLoaderPlugin = require("vue-loader/lib/plugin");
const CopyPlugin = require('copy-webpack-plugin');

module.exports = {
  mode: "production",
  devtool: "inline-source-map",
  devServer: {
    contentBase: "./dist"
  },
  entry: "./src/index.js",
  output: {
    path: path.resolve(__dirname, "dist"),
    filename: "index.bundle.js"
  },
  resolve: {
    alias: {
      icons: path.resolve(__dirname, "node_modules/vue-material-design-icons")
    }
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        use: "vue-loader"
      },
      {
        test: /\.css$/,
        use: ["vue-style-loader", "css-loader"]
      },
      {
        test: /\.scss$/,
        use: ["vue-style-loader", "css-loader", "postcss-loader", "sass-loader"]
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "./src/index.html"
    }),
    new VueLoaderPlugin(),
    new CopyPlugin([{ from: path.resolve(__dirname, "src/icons/favicon") }])
  ]
};
