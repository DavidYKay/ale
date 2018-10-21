" Author: David Kay <davidykay@gmail.com>
" Description: zig linting for zig files
  
function! ale_linters#zig#zig#Handle(buffer, lines) abort
    "let l:pattern = '([^:]+):([^:]+):([^:]+): (.+)\n(.+)\n(\s+\^)'
    "let l:pattern = '([^:]+):([^:]+):([^:]+): (\w+): (.+)\n(.+)\n(\s+\^)'
    "let l:pattern = '([^:]+):([^:]+):([^:]+): (.+)'
    "let l:pattern = '\v^([^:]+):([^:]+):([^:]+): (.+)\n(.+)\n(\s+\^)$'

    let l:pattern = '\v^([^:]+):(.+):(.+):(.+)$'
    let l:output = []

    let bufFile = expand('%:p')

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
      if bufFile == l:match[1]
        let l:item = {
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'type': "error",
        \   'text': l:match[4],
        \}
        "\   'code': l:match[4],

        call add(l:output, l:item)
      else
        echo "Found file:" . l:match[1] . "  expected file: " . bufFile
      endif
    endfor

    return l:output
endfunction

call ale#linter#Define('zig', {
\   'name': 'zig',
\   'output_stream': 'stderr',
\   'executable': 'zig',
\   'command': 'zig build',
\   'callback': 'ale_linters#zig#zig#Handle',
\})
