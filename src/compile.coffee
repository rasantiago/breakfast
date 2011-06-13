fs = require('fs')
path = require('path')

breakfast = require('./breakfast')

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
