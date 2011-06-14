var breakfast, dest, file, files, fs, path, src, start_idx, watch, _fn, _i, _len;
fs = require('fs');
path = require('path');
watch = require('watch');
breakfast = require('breakfast');
if (!(process.argv[2] != null) || !(process.argv[3] != null)) {
  console.log("Usage: brunch source_directory compiled_directory");
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
watch.createMonitor(src, function(monitor) {
  monitor.on("created", function(file, stat) {
    var dst_file, src_file;
    console.log('SRC: Created ' + file);
    dst_file = path.normalize(dest + file.substr(start_idx));
    src_file = path.normalize(file);
    breakfast.processFile(src_file, dst_file);
    return console.log('DST: Wrote ' + dst_file);
  });
  monitor.on("changed", function(file, curr, prev) {
    var dst_file, src_file;
    if (curr.mtime.toString() !== prev.mtime.toString()) {
      console.log('SRC: Changed ' + file);
      dst_file = path.normalize(dest + file.substr(start_idx));
      src_file = path.normalize(file);
      breakfast.processFile(src_file, dst_file);
      return console.log('DST: Wrote ' + dst_file);
    }
  });
  return monitor.on("removed", function(file, stat) {
    var dst_file;
    console.log('SRC: Removed ' + file);
    dst_file = path.normalize(dest + file.substr(start_idx));
    fs.unlinkSync(dst_file);
    return console.log('DST: Removed ' + dst_file);
  });
});