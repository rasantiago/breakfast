var breakfast, dest, file, files, fs, path, src, start_idx, _fn, _i, _len;
fs = require('fs');
path = require('path');
breakfast = require('./breakfast');
if (!(process.argv[2] != null) || !(process.argv[3] != null)) {
  console.log("Usage: breakfast source_directory compiled_directory");
  return;
}
src = path.normalize(process.cwd() + '/' + process.argv[2] + '/');
dest = path.normalize(process.cwd() + '/' + process.argv[3] + '/');
start_idx = src.length;
files = require('findit').findSync(src);
_fn = function(file) {
  var dst_file, src_file;
  dst_file = path.normalize(dest + file.substr(start_idx));
  src_file = path.normalize(file);
  return breakfast.processFile(src_file, dst_file);
};
for (_i = 0, _len = files.length; _i < _len; _i++) {
  file = files[_i];
  _fn(file);
}