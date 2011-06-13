fs = require('fs')
path = require('path')
watch = require('watch')

require('breakfast')

src = path.normalize(process.cwd()+'/'+process.argv[2]+'/')
dest = path.normalize(process.cwd()+'/'+process.argv[3]+'/')

start_idx = src.length

files = require('findit').findSync src 

for file in files
  do(file) ->
    dst_file = path.normalize(dest+file.substr(start_idx))
    src_file = path.normalize file
    console.log src_file
    console.log dst_file
    breakfast.processFile src_file,dst_file
    console.log 'done'

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
    
