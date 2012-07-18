" Language:    Sibilant
" Maintainer:  Joe Fiorini <joe@joefiorini.com>
" URL:         http://github.com/joefiorini/vim-sibilant
" License:     WTFPL

if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

setlocal formatoptions-=t formatoptions+=croql
setlocal comments=:#
setlocal commentstring=#\ %s
setlocal omnifunc=javascriptcomplete#CompleteJS
setlocal lisp

" Enable SibilantMake if it won't overwrite any settings.
if !len(&l:makeprg)
  compiler sibilant
endif

" Check here too in case the compiler above isn't loaded.
if !exists('sibilant_compiler')
  let sibilant_compiler = 'sibilant'
endif

" Reset the SibilantCompile variables for the current buffer.
function! s:SibilantCompileResetVars()
  " Compiled output buffer
  let b:sibilant_compile_buf = -1
  let b:sibilant_compile_pos = []

  " If SibilantCompile is watching a buffer
  let b:sibilant_compile_watch = 0
endfunction

" Clean things up in the source buffer.
function! s:SibilantCompileClose()
  exec bufwinnr(b:sibilant_compile_src_buf) 'wincmd w'
  silent! autocmd! SibilantCompileAuWatch * <buffer>
  call s:SibilantCompileResetVars()
endfunction

" Update the SibilantCompile buffer given some input lines.
function! s:SibilantCompileUpdate(startline, endline)
  let input = getline(a:startline, a:endline)
  let filename = expand("%")

  " Move to the SibilantCompile buffer.
  exec bufwinnr(b:sibilant_compile_buf) 'wincmd w'

  " Sibilant doesn't like empty input.
  if !len(input)
    return
  endif

  echo filename
  " Compile input.
  let output = system(g:sibilant_compiler . ' ' . filename . ' 2>&1')

  " Be sure we're in the SibilantCompile buffer before overwriting.
  if exists('b:sibilant_compile_buf')
    echoerr 'SibilantCompile buffers are messed up'
    return
  endif

  " Replace buffer contents with new output and delete the last empty line.
  setlocal modifiable
    exec '% delete _'
    put! =output
    exec '$ delete _'
  setlocal nomodifiable

  " Highlight as JavaScript if there is no compile error.
  if v:shell_error
    setlocal filetype=
  else
    setlocal filetype=javascript
  endif

  call setpos('.', b:sibilant_compile_pos)
endfunction

" Update the SibilantCompile buffer with the whole source buffer.
function! s:SibilantCompileWatchUpdate()
  call s:SibilantCompileUpdate(1, '$')
  exec bufwinnr(b:sibilant_compile_src_buf) 'wincmd w'
endfunction

" Peek at compiled Sibilant in a scratch buffer. We handle ranges like this
" to prevent the cursor from being moved (and its position saved) before the
" function is called.
function! s:SibilantCompile(startline, endline, args)
  if !executable(g:sibilant_compiler)
    echoerr "Can't find Sibilant compiler `" . g:sibilant_compiler . "`"
    return
  endif

  " If in the SibilantCompile buffer, switch back to the source buffer and
  " continue.
  if !exists('b:sibilant_compile_buf')
    exec bufwinnr(b:sibilant_compile_src_buf) 'wincmd w'
  endif

  " Parse arguments.
  let watch = a:args =~ '\<watch\>'
  let unwatch = a:args =~ '\<unwatch\>'
  let size = str2nr(matchstr(a:args, '\<\d\+\>'))

  " Determine default split direction.
  if exists('g:sibilant_compile_vert')
    let vert = 1
  else
    let vert = a:args =~ '\<vert\%[ical]\>'
  endif

  " Remove any watch listeners.
  silent! autocmd! SibilantCompileAuWatch * <buffer>

  " If just unwatching, don't compile.
  if unwatch
    let b:sibilant_compile_watch = 0
    return
  endif

  if watch
    let b:sibilant_compile_watch = 1
  endif

  " Build the SibilantCompile buffer if it doesn't exist.
  if bufwinnr(b:sibilant_compile_buf) == -1
    let src_buf = bufnr('%')
    let src_win = bufwinnr(src_buf)

    " Create the new window and resize it.
    if vert
      let width = size ? size : winwidth(src_win) / 2

      belowright vertical new
      exec 'vertical resize' width
    else
      " Try to guess the compiled output's height.
      let height = size ? size : min([winheight(src_win) / 2,
      \                               a:endline - a:startline + 2])

      belowright new
      exec 'resize' height
    endif

    " We're now in the scratch buffer, so set it up.
    setlocal bufhidden=wipe buftype=nofile
    setlocal nobuflisted nomodifiable noswapfile nowrap

    autocmd BufWipeout <buffer> call s:SibilantCompileClose()
    " Save the cursor when leaving the SibilantCompile buffer.
    autocmd BufLeave <buffer> let b:sibilant_compile_pos = getpos('.')

    nnoremap <buffer> <silent> q :hide<CR>

    let b:sibilant_compile_src_buf = src_buf
    let buf = bufnr('%')

    " Go back to the source buffer and set it up.
    exec bufwinnr(b:sibilant_compile_src_buf) 'wincmd w'
    let b:sibilant_compile_buf = buf
  endif

  if b:sibilant_compile_watch
    call s:SibilantCompileWatchUpdate()

    augroup SibilantCompileAuWatch
      autocmd BufWritePost <buffer> call s:SibilantCompileWatchUpdate()
    augroup END
  else
    call s:SibilantCompileUpdate(a:startline, a:endline)
  endif
endfunction

" Complete arguments for the SibilantCompile command.
function! s:SibilantCompileComplete(arg, cmdline, cursor)
  let args = ['unwatch', 'vertical', 'watch']

  if !len(a:arg)
    return args
  endif

  let match = '^' . a:arg

  for arg in args
    if arg =~ match
      return [arg]
    endif
  endfor
endfunction

" Don't overwrite the SibilantCompile variables.
if !exists('b:sibilant_compile_buf')
  call s:SibilantCompileResetVars()
endif

" Peek at compiled Sibilant.
command! -range=% -bar -nargs=* -complete=customlist,s:SibilantCompileComplete
\        SibilantCompile call s:SibilantCompile(<line1>, <line2>, <q-args>)
" Run some Sibilant.
command! -range=% -bar SibilantRun <line1>,<line2>:w !sibilant -x
