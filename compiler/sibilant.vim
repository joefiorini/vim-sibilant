" Language:    Sibilant
" Maintainer:  Joe Fiorini <joe@joefiorini.com>
" URL:         http://github.com/joefiorini/vim-sibilant
" License:     WTFPL

if exists('current_compiler')
  finish
endif

let current_compiler = 'sibilant'
" Pattern to check if sibilant is the compiler
let s:pat = '^' . current_compiler

" Path to Sibilant compiler
if !exists('sibilant_compiler')
  let sibilant_compiler = 'sibilant'
endif

" Extra options passed to SibilantMake
if !exists('sibilant_make_options')
  let sibilant_make_options = ''
endif

" Get a `makeprg` for the current filename. This is needed to support filenames
" with spaces and quotes, but also not break generic `make`.
function! s:GetMakePrg()
  return g:sibilant_compiler . ' ' . g:sibilant_make_options . ' $* '
  \                        . fnameescape(expand('%'))
endfunction

" Set `makeprg` and return 1 if sibilant is still the compiler, else return 0.
function! s:SetMakePrg()
  if &l:makeprg =~ s:pat
    let &l:makeprg = s:GetMakePrg()
  elseif &g:makeprg =~ s:pat
    let &g:makeprg = s:GetMakePrg()
  else
    return 0
  endif

  return 1
endfunction

" Set a dummy compiler so we can check whether to set locally or globally.
CompilerSet makeprg=sibilant
call s:SetMakePrg()

CompilerSet errorformat=Error:\ In\ %f\\,\ %m\ on\ line\ %l,
                       \Error:\ In\ %f\\,\ Parse\ error\ on\ line\ %l:\ %m,
                       \SyntaxError:\ In\ %f\\,\ %m,
                       \%-G%.%#

" Compile the current file.
command! -bang -bar -nargs=* SibilantMake make<bang> <args>

" Set `makeprg` on rename since we embed the filename in the setting.
augroup SibilantUpdateMakePrg
  autocmd!

  " Update `makeprg` if sibilant is still the compiler, else stop running this
  " function.
  function! s:UpdateMakePrg()
    if !s:SetMakePrg()
      autocmd! SibilantUpdateMakePrg
    endif
  endfunction

  " Set autocmd locally if compiler was set locally.
  if &l:makeprg =~ s:pat
    autocmd BufFilePost,BufWritePost <buffer> call s:UpdateMakePrg()
  else
    autocmd BufFilePost,BufWritePost          call s:UpdateMakePrg()
  endif
augroup END

