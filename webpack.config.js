const path = require("path");
const webpack = require("webpack");
const WebpackBar = require("webpackbar");
const NotifierPlugin = require("webpack-notifier");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");

const stats = {
  all: false,
  assets: true,
  cachedAssets: true,
  children: false,
  chunks: false,
  entrypoints: true,
  errorDetails: true,
  errors: true,
  hash: true,
  modules: false,
  performance: true,
  publicPath: true,
  timings: true,
  warnings: false,
  exclude: ["node_modules"]
};

module.exports = (env, argv) => {
  return {
    node: {
      fs: "empty"
    },
    mode: argv.mode,
    entry: {
      "js/script": "./wp-content/themes/test/src/test.js"
    },
    output: {
      filename: "dist/[name].[contenthash:6].js",
      chunkFilename: "[name].[contenthash:6].js",
      path: path.resolve(__dirname, "wp-content/themes/test"),
      publicPath: "/wp-content/themes/test/"
    },
    resolve: {
      extensions: [".js", ".ts", ".json", ".less", ".s(a|c)ss", ".css"]
    },
    module: {
      rules: [
        {
          test: /\.js$/,
          use: ["babel-loader", "eslint-loader", "import-glob"],
          exclude: "/node_modules/"
        },
        {
          test: /\.css$/,
          use: [
            {
              loader: MiniCssExtractPlugin.loader
            },
            {
              loader: "css-loader",
              options: {
                importLoaders: 1
              }
            },
            "postcss-loader"
          ]
        },
        {
          test: /\.scss$/,
          use: [
            {
              loader: MiniCssExtractPlugin.loader
            },
            {
              loader: "css-loader",
              options: {
                url: false,
                importLoaders: 1
              }
            },
            "postcss-loader",
            "sass-loader"
          ]
        }
      ]
    },
    plugins: [
      new WebpackBar(),
      new NotifierPlugin({
        alwaysNotify: true,
        contentImage: path.join(__dirname, "logo.png"),
        skipFirstNotification: true
      }),
      new CleanWebpackPlugin({
        cleanOnceBeforeBuildPatterns: ["dist/js/**/*", "dist/css/**/*"]
      }),
      new MiniCssExtractPlugin({
        filename: "dist/css/style.[contenthash:6].css"
      }),
      new webpack.DefinePlugin({
        "process.env.NODE_ENV": JSON.stringify("production")
      })
    ],
    stats: stats,
    performance: {
      hints: false
    },
    optimization: {
      splitChunks: {
        automaticNameDelimiter: "/",
        cacheGroups: {
          default: false,
          dist: {
            test: /[\\/]node_modules[\\/]/,
            priority: -10,
            enforce: true
          }
        }
      },
      minimizer: [
        new OptimizeCSSAssetsPlugin({
          cssProcessorOptions: {
            discardComments: {
              removeAll: true
            },
            discardEmpty: true,
            discardOverridden: true
          }
        }),
        new TerserPlugin({
          parallel: true,
          terserOptions: {}
        })
      ]
    }
  };
};
