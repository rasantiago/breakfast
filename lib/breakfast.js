var coffee, createPathForFile, fs, haml, path, processCoffee, processContent, processHAML, processJS, recurseFilePathList;
coffee = require('coffee-script');
haml = require('haml');
fs = require('fs');
path = require('path');
recurseFilePathList = function(paths, files, callback) {
  var working;
  if (0 === paths.length) {
    return callback(files);
  }
  working = paths.shift();
  try {
    fs.exists(working, function(exists) {
      if (!exists) {
        try {
          return fs.mkdirSync(working, 0755, function() {
            return recurseFilePathList(paths, files, callback);
          });
        } catch (e) {
          return console.log(new Error("Failed to create path: " + working + " with " + e.toString()));
        }
      } else {
        return recurseFilePathList(paths, files, callback);
      }
    });
  } catch (e) {
    console.log(new Error("Invalid path specified: " + working));
  }
};
createPathForFile = function(files, callback) {
  var part, parts, pathList, working, _i, _len;
  parts = path.dirname(path.normalize(files.dst));
  parts = parts.split('/');
  working = '/';
  pathList = [];
  for (_i = 0, _len = parts.length; _i < _len; _i++) {
    part = parts[_i];
    working = path.join(working, part);
    pathList.push(working);
  }
  if (pathList.length === 0) {
    return console.log(new Error("Path list was empty"));
  } else {
    return recurseFilePathList(pathList, files, callback);
  }
};
processCoffee = function(content) {
  var chunk, chunks, _fn, _i, _len;
  chunks = content.match(/<\?coffee([\s\S]*?)\?>/g);
  if (!chunks) {
    return content;
  }
  _fn = function(chunk) {
    var temp;
    temp = chunk.match(/<\?coffee([\s\S]*?)\?>/)[1];
    temp = coffee.compile(temp, {
      bare: true
    });
    return content = content.replace(chunk, temp);
  };
  for (_i = 0, _len = chunks.length; _i < _len; _i++) {
    chunk = chunks[_i];
    _fn(chunk);
  }
  return content;
};
processHAML = function(content) {
  var chunk, chunks, _fn, _i, _len;
  chunks = content.match(/<\?haml([\s\S]*?)\?>/g);
  if (!chunks) {
    return content;
  }
  _fn = function(chunk) {
    var temp;
    temp = chunk.match(/<\?haml([\s\S]*?)\?>/)[1];
    return content = content.replace(chunk, haml.render(temp));
  };
  for (_i = 0, _len = chunks.length; _i < _len; _i++) {
    chunk = chunks[_i];
    _fn(chunk);
  }
  return content;
};
processJS = function(content) {
  var chunk, chunks, _fn, _i, _len;
  chunks = content.match(/<\?js([\s\S]*?)\?>/g);
  if (!chunks) {
    return content;
  }
  _fn = function(chunk) {
    var temp;
    temp = chunk.match(/<\?js([\s\S]*?)\?>/)[1];
    return content = content.replace(chunk, temp);
  };
  for (_i = 0, _len = chunks.length; _i < _len; _i++) {
    chunk = chunks[_i];
    _fn(chunk);
  }
  return content;
};
processContent = function(content) {
  content = processCoffee(content);
  content = processHAML(content);
  content = processJS(content);
  return content;
};
exports.processFile = function(src_file, dst_file) {
  var files;
  try {
    if (fs.lstatSync(src_file).isDirectory()) {
      return;
    }
    files = {
      src: src_file,
      dst: dst_file
    };
    return createPathForFile(files, function(files) {
      var content;
      content = fs.readFileSync(files.src, "utf-8");
      content = processContent(content);
      return fs.writeFileSync(files.dst, content, "utf-8");
    });
  } catch (e) {
    return console.log(e);
  }
};