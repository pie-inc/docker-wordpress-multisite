import path from 'path';
import fs from 'fs';
import webpack from 'webpack';
import ExtractTextPlugin from 'extract-text-webpack-plugin';
import NotifierPlugin from 'webpack-notifier';
import OptimizeCssAssetsPlugin from 'optimize-css-assets-webpack-plugin';

const entries = fs.readdirSync('./code/src')
        .filter((file) => file.match(/.*\.js$/))
        .map((file) => {
          return {
            name: file.substring(0, file.length - 3),
            path: './code/src/' + file
          }
        }).reduce((memo, file) => {
          memo[file.name] = file.path
          return memo;
        },{});

export default {
  entry: entries,
  output: {
    filename: 'code/themes/[name]/dist/scripts.min.js',
    pathinfo: true
  },
  resolve: {
    extensions: [".js", ".ts", ".json", ".less", ".scss", ".css"]
  },
  module: {
    rules: [
      { test: /\.js$/, use: 'babel-loader' },
      { test: /\.tsx?$/, loader: "ts-loader" },
      {
        test: /.(png|jpg|gif|woff(2)?|eot|ttf|svg)$/,
        loader: 'file-loader',
        query: {
          emitFile: false,
          name: '[name].[ext]',
          useRelativePath: true
        }
      },
      {
        test: /\.css$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: [
            { loader: 'css-loader', options: { importLoaders: 1 } },
            'postcss-loader'
          ]
        })
      }
    ]
  },
  plugins: [
    new NotifierPlugin({ alwaysNotify: true, skipFirstNotification: true }),
    new webpack.optimize.UglifyJsPlugin({ sourceMap: true }),
    new ExtractTextPlugin('code/themes/[name]/dist/style.min.css'),
    new OptimizeCssAssetsPlugin({
      assetNameRegExp: /\.min\.css$/g,
      cssProcessorOptions: {
        discardComments: { removeAll: true },
        discardEmpty: true,
        discardOverridden: true
      }
    })
  ],
  devtool: 'source-map',
  watch: true
};
