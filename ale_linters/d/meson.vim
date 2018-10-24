" Author: David Y. Kay <davidykay@gmail.com>
" Description: "meson for D files, via Meson"

function! ale_linters#d#meson#MesonCommand(buffer) abort
    return "meson introspect --target-files d@@gc@exe /home/dk/workspace/current/mccarthy/build"
endfunction

function! ale_linters#d#meson#ProjectRoot(buffer) abort
    for l:path in ale#path#Upwards(expand('#2:p:h'))
        if isdirectory(l:path . '/.git')
          return l:path
        endif
    endfor
endfunction

function! ale_linters#d#meson#DMDCommand(buffer, meson_output) abort
  let l:dir_dict = {}
  let lines = webapi#json#decode(a:meson_output[0])

  let l:cwd = ale_linters#d#meson#ProjectRoot(a:buffer)

  " Build a list of import paths generated from Meson, if available.
  for l:line in lines
    if !empty(l:line)
      let dir = '-I' . cwd . '/' . fnamemodify(l:line, ':h')
      let l:dir_dict[dir] = 1
    endif
  endfor
  
  return 'dmd '. join(keys(l:dir_dict)) . ' -o- -wi -vcolumns -c %t'
endfunction

function! ale_linters#d#meson#Handle(buffer, lines) abort
    " Matches patterns lines like the following:
    " /tmp/tmp.qclsa7qLP7/file.d(1): Error: function declaration without return type. (Note that constructors are always named 'this')
    " /tmp/tmp.G1L5xIizvB.d(8,8): Error: module weak_reference is in file 'dstruct/weak_reference.d' which cannot be read
    let l:pattern = '^[^(]\+(\([0-9]\+\)\,\?\([0-9]*\)): \([^:]\+\): \(.\+\)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1],
        \   'col': l:match[2],
        \   'type': l:match[3] is# 'Warning' ? 'W' : 'E',
        \   'text': l:match[4],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('d', {
\   'name': 'meson',
\   'executable': 'meson',
\   'command_chain': [
\       {'callback': 'ale_linters#d#meson#MesonCommand', 'output_stream': 'stdout'},
\       {'callback': 'ale_linters#d#meson#DMDCommand', 'output_stream': 'stderr'},
\   ],
\   'callback': 'ale_linters#d#meson#Handle',
\})
