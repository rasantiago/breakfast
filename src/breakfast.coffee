coffee = require('coffee-script')
haml = require('haml')
fs = require('fs')
path = require('path')

recurseFilePathList = (paths,files,callback) ->
  if 0 == paths.length
    return callback(files)
  working = paths.shift()
  try
    path.exists working, (exists)->
      if not exists
        try
          fs.mkdirSync working, 0755, () ->
            recurseFilePathList paths,files,callback
        catch e
          console.log(new Error("Failed to create path: " + working + " with " + e.toString()))
      else
        recurseFilePathList paths,files,callback
  catch e
    console.log(new Error("Invalid path specified: " + working))
  return

createPathForFile = (files,callback) ->
  parts = path.dirname path.normalize(files.dst)
  parts = parts.split '/'
  working = '/'
  pathList = []
  for part in parts
	  working = path.join working, part
	  pathList.push working
  if pathList.length == 0
    console.log(new Error("Path list was empty"))
  else
    recurseFilePathList pathList,files,callback

processCoffee = (content) ->
  chunks = content.match(/<\?coffee([\s\S]*?)\?>/g)
  return content if not chunks
  for chunk in chunks
    do (chunk) ->
      temp = chunk.match(/<\?coffee([\s\S]*?)\?>/)[1]
      temp = coffee.compile(temp,{bare: true})
      content = content.replace(chunk,temp)
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

processContent = (content) ->
  content = processCoffee content
  content = processHAML content
  content = processJS content
  return content

exports.processFile = (src_file,dst_file) ->
  try
    return if fs.lstatSync(src_file).isDirectory()
    files = src: src_file, dst: dst_file
    createPathForFile files,(files) ->
      content = fs.readFileSync files.src,"utf-8"
      content = processContent content
      fs.writeFileSync files.dst,content,"utf-8"
  catch e
    console.log e






