coffee = require('coffee-script')
haml = require('haml')
fs = require('fs')
path = require('path')
watch = require('watch')

src = 'breakfast'
dest = 'compiled'
start_idx = src.length
files = require('findit').findSync src 

recurseFilePathList = (paths,file,callback) ->
  if 0 == paths.length
    return callback(file)
  working = paths.shift()
  try
    path.exists working, (exists)->
      if not exists
        try
          fs.mkdir working, 0755, () ->
            recurseFilePathList paths,file,callback
        catch e
          console.log(new Error("Failed to create path: " + working + " with " + e.toString()))
      else
        recurseFilePathList paths,file,callback
  catch e
    console.log(new Error("Invalid path specified: " + working))
  return

createPathForFile = (file,callback) ->
  fullPath = path.dirname(path.resolve(dest+file.substr(start_idx)))
  parts = path.normalize(fullPath)
  parts = parts.split '/'
  working = '/'
  pathList = []

  for part in parts
	  working = path.join working, part
	  pathList.push working
  if pathList.length == 0
    console.log(new Error("Path list was empty"))
  else
    recurseFilePathList pathList,file,callback

processCoffee = (content) ->
  chunks = content.match(/<\?coffee([\s\S]*?)\?>/g)
  return content if not chunks
  for chunk in chunks
    do (chunk) ->
      temp = chunk.match(/<\?coffee([\s\S]*?)\?>/)[1]
      content = content.replace(chunk,coffee.compile(temp))
  return content

processHAML = (content) ->
  chunks = content.match(/<\?haml([\s\S]*?)\?>/g)
  return content if not chunks
  for chunk in chunks
    do (chunk) ->
      temp = chunk.match(/<\?haml([\s\S]*?)\?>/)[1]
      content = content.replace(chunk,haml.render(temp))
  return content

processJS = (content) ->
  chunks = content.match(/<\?js([\s\S]*?)\?>/g)
  return content if not chunks
  for chunk in chunks
    do (chunk) ->
      temp = chunk.match(/<\?js([\s\S]*?)\?>/)[1]
      content = content.replace(chunk,temp)
  return content

processFileContent = (file) ->
  content = fs.readFileSync file,"utf-8"
  content = processCoffee content
  content = processHAML content
  content = processJS content
  fs.writeFileSync dest+file.substr(start_idx),content,"utf-8"

processFile = (file) ->
  try
    createPathForFile file,processFileContent
  catch e
    error.log e

#processFile file for file in files

#content = fs.readFileSync 'test2.txt',"utf-8"
#a = content.match(/<\?coffee([\s\S]*?)\?>/g)
#console.log(content.replace(a[0],coffee.compile(a[1],{bare: true})))
#console.log(a[0].match(/<\?coffee([\s\S]*?)\?>/)[1])

watch.createMonitor src, (monitor) ->
  monitor.on "created", (f, stat) ->
    console.log 'SRC: Created '+f
    processFile f
    console.log 'DST: Wrote '+dest+f.substr(start_idx)  
  monitor.on "changed", (f, curr, prev) ->
    console.log "change event"
    if curr.mtime.toString() != prev.mtime.toString()
      console.log curr
      console.log prev
      console.log 'SRC: Changed '+f
      processFile f
      console.log 'DST: Wrote '+dest+f.substr(start_idx)  
  monitor.on "removed", (f, stat) ->
    console.log 'SRC: Removed '+f
    fs.unlinkSync dest+f.substr(start_idx)
    console.log 'DST: Removed '+dest+f.substr(start_idx)
