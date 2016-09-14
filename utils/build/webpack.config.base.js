const webpack = require('webpack');
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

const srcPath = path.join(__dirname, '../../src');
const outPath = path.join(__dirname, '../../dist');

module.exports = {
  __srcPath__: srcPath,
  __outPath__: outPath,

  publicPath: '/',

  module: {
    loaders: [{
      test: /\.js$/,
      exclude: [/elm-stuff/, /node_modules/],
      loader: 'babel',
      query: {
        presets: ['es2015']
      },
    }, {
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      loader: 'elm-webpack',
    }],
  },

  entry: {
    main: path.join(srcPath, '/index.js'),
  },

  output: {
    path: outPath,
    filename: '[name].js',
    publicPath: '/',
  },

  resolve: {},

  plugins: [
    new HtmlWebpackPlugin({
      template: path.join(srcPath, 'index.html'),
      filename: 'index.html',
      inject: 'body',
      chunks: ['main'],
    }),
  ],

  externals: [],
};
