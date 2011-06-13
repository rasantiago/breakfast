(function() {
  var dest, fs, path, src, watch;
  fs = require('fs');
  path = require('path');
  watch = require('watch');
  require('breakfast');
  src = path.normalize(process.cwd() + '/' + process.argv[2] + '/');
  dest = path.normalize(process.cwd() + '/' + process.argv[3] + '/');
  watch.createMonitor(src, function(monitor) {
    monitor.on("created", function(f, stat) {
      console.log('SRC: Created ' + f);
      processFile(f);
      return console.log('DST: Wrote ' + dest + f.substr(start_idx));
    });
    monitor.on("changed", function(f, curr, prev) {
      console.log("change event");
      if (curr.mtime.toString() !== prev.mtime.toString()) {
        console.log(curr);
        console.log(prev);
        console.log('SRC: Changed ' + f);
        processFile(f);
        return console.log('DST: Wrote ' + dest + f.substr(start_idx));
      }
    });
    return monitor.on("removed", function(f, stat) {
      console.log('SRC: Removed ' + f);
      fs.unlinkSync(dest + f.substr(start_idx));
      return console.log('DST: Removed ' + dest + f.substr(start_idx));
    });
  });
}).call(this);
