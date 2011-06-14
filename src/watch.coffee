fs = require('fs')
path = require('path')
watch = require('watch')

breakfast = require('breakfast')

if not process.argv[2]? or not process.argv[3]?
  console.log "Usage: brunch source_directory compiled_directory"
  return 

src = path.normalize(process.cwd()+'/'+process.argv[2]+'/')
dest = path.normalize(process.cwd()+'/'+process.argv[3]+'/')

start_idx = src.length

files = require('findit').findSync src 

for file in files
  do(file) ->
    dst_file = path.normalize(dest+file.substr(start_idx))
    src_file = path.normalize file
    breakfast.processFile src_file,dst_file

watch.createMonitor src, (monitor) ->
  monitor.on "created", (file, stat) ->
    console.log 'SRC: Created '+ file
    dst_file = path.normalize(dest+file.substr(start_idx))
    src_file = path.normalize file
    breakfast.processFile src_file,dst_file
    console.log 'DST: Wrote '+ dst_file  
  monitor.on "changed", (file, curr, prev) ->
    if curr.mtime.toString() != prev.mtime.toString()
      console.log 'SRC: Changed '+ file
      dst_file = path.normalize(dest+file.substr(start_idx))
      src_file = path.normalize file
      breakfast.processFile src_file,dst_file
      console.log 'DST: Wrote '+ dst_file  
  monitor.on "removed", (file, stat) ->
    console.log 'SRC: Removed '+ file
    dst_file = path.normalize(dest+file.substr(start_idx))
    fs.unlinkSync dst_file
    console.log 'DST: Removed '+ dst_file
    
