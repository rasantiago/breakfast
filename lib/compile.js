(function() {
  var breakfast, dest, file, files, fs, path, src, start_idx, _fn, _i, _len;
  fs = require('fs');
  path = require('path');
  breakfast = require('./breakfast');
  src = path.normalize(process.cwd() + '/' + process.argv[2] + '/');
  dest = path.normalize(process.cwd() + '/' + process.argv[3] + '/');
  start_idx = src.length;
  files = require('findit').findSync(src);
  _fn = function(file) {
    var dst_file, src_file;
    dst_file = path.normalize(dest + file.substr(start_idx));
    src_file = path.normalize(file);
    console.log(src_file);
    console.log(dst_file);
    breakfast.processFile(src_file, dst_file);
    return console.log('done');
  };
  for (_i = 0, _len = files.length; _i < _len; _i++) {
    file = files[_i];
    _fn(file);
  }
}).call(this);
