" Language:    Sibilant
" Maintainer:  Joe Fiorini <joe@joefiorini.com>
" URL:         http://github.com/joefiorini/vim-sibilant
" License:     WTFPL


autocmd BufNewFile,BufRead *.sibilant set filetype=sibilant

function! s:DetectSibilant()
    if getline(1) =~ '^#!.*\<sibilant\>'
        set filetype=sibilant
    endif
endfunction

autocmd BufNewFile,BufRead * call s:DetectSibilant()

