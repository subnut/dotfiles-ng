source ~/.vimrc
color PaperColor

call plug#begin('~/.config/nvim/plugged')
Plug 'subnut/nvim-ghost.nvim', { 'do': ':call nvim_ghost#installer#install()' }
call plug#end()
