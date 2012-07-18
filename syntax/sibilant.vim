" Language:    Sibilant
" Maintainer:  Joe Fiorini <joe@joefiorini.com>
" URL:         http://github.com/joefiorini/vim-sibilant
" License:     WTFPL

" Bail if our syntax is already loaded.
if exists('b:current_syntax') && b:current_syntax == 'sibilant'
  finish
endif

" Include Lisp
source $VIMRUNTIME/syntax/lisp.vim
