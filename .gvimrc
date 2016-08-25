" Use the Solarized Dark theme
set background=dark
colorscheme solarized
" Use 14pt Monaco
set guifont=Monaco:h14
" Don’t blink cursor in normal mode
set guicursor=n:blinkon0
" Better line-height
set linespace=8

function! SQL2Tab()
        %s#^|\s*##g
        %s#\s*|\s*#\t#g
        g/-----/d
endfunction
set syntax on
set filetype plugin indent on
