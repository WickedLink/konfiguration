set nu
set noerrorbells
set guicursor=
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l> " Highlighting der Suche ausschalten
nnoremap <F3> :set hlsearch! hlsearch?<CR> " Highlighting der Suche ausschalten
" set termguicolors
" colorscheme evening


set statusline=
set statusline+=%1*
" set statusline+=%{StatuslineMode()}
   " set statusline+=%#DiffAdd#%{(mode()=='n')?'\ \ NORMAL\ ':''}
   set statusline+=%1*%{(mode()=='n')?'\ \ NORMAL\ ':''}
   set statusline+=%#DiffChange#%{(mode()=='i')?'\ \ INSERT\ ':''}
   set statusline+=%#DiffDelete#%{(mode()=='r')?'\ \ RPLACE\ ':''}
   set statusline+=%#Cursor#%{(mode()=='v')?'\ \ VISUAL\ ':''}
   set statusline+=%1*
   set statusline+=\ 
set statusline+=:
set statusline+=\ 
set statusline+=%m
set statusline+=\ 
" set statusline+=|
set statusline+=\ 
set statusline+=%2*
set statusline+=%3*
" set statusline+=\
set statusline+=\
set statusline+=\ 
set statusline+=%F
set statusline+=%=
set statusline+=%3*
" set statusline+=\ 
set statusline+=%1*
set statusline+=\ 
" set statusline+=
set statusline+=%y
" set statusline+=
" set statusline+=<
" set statusline+=%{&ff}
" set statusline+=>
" set statusline+=<
" set statusline+=%{strlen(&fenc)?&fenc:'none'}
" set statusline+=>
" set statusline+=\ 
" set statusline+=|
" set statusline+=\ 
" set statusline+=%l
" set statusline+=:
" set statusline+=%c
" set statusline+=\ 
" set statusline+=|
" set statusline+=\ 
" set statusline+=%L
" set statusline+=\ 
" set statusline+=|
" set statusline+=\ 
" set statusline+=<
" set statusline+=%P
" set statusline+=>
" set statusline+=\ 
" set statusline+=|
" set statusline+=\ 
" set statusline+=%{strftime(\"%H:%M\")}
" set statusline+=%3*
" set statusline+=|
set statusline+=%4*
" set statusline+=|
hi User1 ctermbg=darkred ctermfg=white guibg=darkred guifg=white
hi User2 ctermbg=darkgray ctermfg=white guibg=darkgray guifg=white
hi User3 ctermbg=darkgray ctermfg=darkred guibg=darkgray guifg=darkred
hi User4 ctermbg=darkred ctermfg=darkgray guibg=darkred guifg=darkgray

function! StatuslineMode()
  let l:mode=mode()
  if l:mode==#"n"
    return "NORMAL"
  elseif l:mode==?"v"
    return "VISUAL"
  elseif l:mode==#"i"
    return "INSERT"
  elseif l:mode==#"R"
    return "REPLACE"
  elseif l:mode==?"s"
    return "SELECT"
  elseif l:mode==#"t"
    return "TERMINAL"
  elseif l:mode==#"c"
    return "COMMAND"
  elseif l:mode==#"!"
    return "SHELL"
  endif
endfunction

set laststatus=2

" color settings for tmux
set background=dark
set t_Co=256
