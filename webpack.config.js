/*

The entirety of this script is taken from the equivalent in the leaflet.extras
package: https://github.com/bhaskarvk/leaflet.extras/blob/master/webpack.config.js

Full credit to bhaskarvk for this script.

*/

const path = require('path');

const binding_path = "./inst/htmlwidgets/bindings/";
const build_path = path.resolve(__dirname, "./inst/htmlwidgets/build");

let library_prod = function(name, filename = name, library = undefined) {
  let foldername = filename;
  filename = filename + "-prod";
  var config = {
	mode: "production", //production run, minifies the file
	entry: name, //entry point is file passed to function
	devtool: "source-map", //produce a sibling source map file
	externals: {
	  // make L available
	  leaflet: "L"
	},
	output: {
	  filename: filename + ".js",
	  path: build_path + "/" + foldername
	}
  };
  if (typeof library != 'undefined') {
    // save the library as a variable
    // https://webpack.js.org/configuration/output/#output-library
    config.output.library = library;
    // do not use 'var' in the assignment
    // https://webpack.js.org/configuration/output/#output-librarytarget
    config.output.libraryTarget = "assign";
  }
  return config;
};

let library_binding = function(name) {
  let filename = binding_path + name + "-bindings.js";
  return {
	mode: "production", // production run, minifies the file
	entry: filename,
	devtool: "source-map", // include external map file
	module: {
	  // lint the bindings using ./inst/htmlwidgets/bindings/.eslintrc.js
	  rules: [
	    {
		  test: /\.js$/,
		  exclude: /node_modules/,
		  loader: "eslint-loader"
	    },
	  ]
	},
	output: {
	  filename: name + "-bindings.js",
	  path: build_path + "/" + name
	}
  };
};

const config = [

  // new targomo API
  library_prod("@targomo/core", "targomo-core", "tgm"),
  library_prod("@targomo/leaflet", "targomo-leaflet", "tgm.leaflet"),
  library_binding("targomo-leaflet")

];

module.exports = config;
