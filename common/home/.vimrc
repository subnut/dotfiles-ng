scriptencoding utf-8
if !has('nvim')
    unlet! skip_defaults_vim
    source $VIMRUNTIME/defaults.vim
endif


set title
set smarttab
set smartcase   " NOTE: by default ignorecase is off, so this is meaningless
set ignorecase
set splitbelow
set splitright
set equalalways
set spelllang=en
set shortmess-=S
set helpheight=0
set updatetime=1000
set timeoutlen=3500
set fileformats=unix,dos

setg nowrap
setg encoding=utf-8
setg spelllang+=en_gb
setg matchpairs+=<:>
setg listchars=nbsp:+

setg listchars=trail:@
" setg listchars=trail:-

setg listchars+=eol:\\u21b2
" setg listchars+=eol:~
" setg listchars+=eol:-
" setg listchars+=eol:$

setg listchars+=tab:>-
" setg listchars+=tab:<->

setg listchars+=precedes:<,extends:>
" setg listchars+=precedes:\\u2190,extends:\\u2192    " left and right arrows
" setg listchars+=precedes:\\u2026,extends:\\u2026    " horizontal ellipsis

let g:showbreak_candidates = ['↳ ', '↪ ', '⤷ ', '⮡ ', '¬ ']
let &g:showbreak = g:showbreak_candidates[2]    " NOTE: Index starts from 0

set mouse=n
map <MiddleMouse>   <Nop>
map <2-MiddleMouse> <Nop>
map <3-MiddleMouse> <Nop>
map <4-MiddleMouse> <Nop>

let mapleader = ' '
noremap  <leader>y "+
nnoremap <leader>l <cmd>set list!<CR>
nnoremap <leader>b :ls<CR>:b<Space>


hi SignColumn ctermbg=none
aug MyClearSignColumn
    au!
    au ColorScheme * hi SignColumn ctermbg=none
aug END


aug ManPlugin
    au!
    au BufWinEnter *.c,*.h  setl kp=:Man
    au BufWinEnter *.~,*.?~ setl kp=:Man
aug END
com! -nargs=+ -complete=shellcmd Man delcom Man | runtime ftplugin/man.vim
            \ | exe expand(<q-mods>) . ' Man ' . expand(<q-args>)


" Auto-correct last incorrect word {{{1
" https://castel.dev/post/lecture-notes-1/#correcting-spelling-mistakes-on-the-fly
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

" Delete surrounding (ds) {{{1
nnoremap <silent><expr> ds 'di' . nr2char(getchar()) . 'vhp'

" Ranger integration {{{1
if exists('$RANGER_LEVEL')
    nmap q <cmd>q<CR>
endif

" GetHiGroup - Get higlight group of the character under cursor {{{1
fun! GetHiGroup()
    return synIDattr(synID(line('.'), col('.'), 1), 'name')
endfun
command! GetHiGroup echo GetHiGroup()

" :Notab -- :retab, but with 'expandtab' set {{{1
com! -range -bang Notab let b:Notab_et = &l:et | let &l:et = 1 | exe
            \ (<range>?(<range>-1)?"<line1>,<line2>":"<line1>":"")."retab"
            \."<bang>" | let &l:et = b:Notab_et | unlet b:Notab_et

" Copy to clipboard {{{1
if !(has('xterm_clipboard') && has('unnamedplus')) " use <leader>y
    noremap <leader>y <cmd>call SyncClipboard()<CR>"z
    aug YankToClipboard
        au!
        au TextYankPost * if v:event.regname ==# 'z' | call CopyToClipboard(
                    \join(v:event.regcontents, "\n")."\n")| endif
    aug END
    if has('unix')
        if executable('xclip') && !empty($DISPLAY)
            fun! CopyToClipboard(text)
                silent! call system('xclip -in -sel clipboard', a:text)
            endfun
            fun! SyncClipboard()
                let @z = system('xclip -out -sel clipboard')
            endfun
        elseif executable('wl-copy') && !empty($WAYLAND_DISPLAY)
            fun! CopyToClipboard(text)
                silent! call system('wl-copy', a:text)
            endfun
            fun! SyncClipboard()
                let @z = system('wl-paste')
                if count(@z, nr2char(10)) == 1
                    let @z = trim(@z, nr2char(10), 2)
                else
                    let @z = trim(@z, nr2char(10), 2) . nr2char(10)
                endif
            endfun
        endif
    endif
endif
" 1}}}
" Swap files {{{1
let s:swapdir = expand(!has('nvim') ? '~/.vimswap' : '~/.config/nvim/swap')
if !isdirectory(fnamemodify(s:swapdir, ':p'))
    if exists('*mkdir')
        call mkdir(fnamemodify(s:swapdir, ':p'), 'p', 0o0700)
        if !isdirectory(fnamemodify(s:swapdir, ':p'))
            let &directory = s:swapdir . '//'
        endif
    else
        echohl WarningMsg
        echom 'Please create ' . s:swapdir . ' directory with with permissions 0700'
        echohl None
    endif
else
    let &directory = s:swapdir . '//'
    if getfperm(fnamemodify(s:swapdir, ':p')) !=# 'rwx------'
        call setfperm(fnamemodify(s:swapdir, ':p'), 'rwx------')
    endif
endif
" 1}}}
" Persistent undo {{{1
let s:undodir = expand(!has('nvim') ? '~/.vimundo' : '~/.config/nvim/undo')
if has('persistent_undo')
    if !isdirectory(fnamemodify(s:undodir, ':p'))
        if exists('*mkdir')
            " NOTE: The execute bit is nessecary, because otherwise we cannot
            " cd into that directory, nor can we create new files in th directory
            call mkdir(fnamemodify(s:undodir, ':p'), 'p', 0o0700)
        else
            echohl WarningMsg
            echom 'Directory ' . s:undodir . ' not available. Persistent undo disabled.'
            echohl None
        endif
    endif
    set undofile
    let &undodir = s:undodir
    if getfperm(fnamemodify(s:undodir, ':p')) !=# 'rwx------'
        call setfperm(fnamemodify(s:undodir, ':p'), 'rwx------')
    endif
else
    echohl WarningMsg
    echom 'Vim not compiled with +persistent_undo. Persistent undo disabled.'
    echohl None
endif
" 1}}}
" Show Trailing Spaces {{{1
" hi TrailingWhitespace term=standout ctermfg=red ctermbg=red guifg=red guibg=red
hi link TrailingWhitespace Error
let w:trailing_whitespace = matchadd('TrailingWhitespace', '\s\+$')
aug TrailingWhitespace
    au!
    " au ColorScheme * hi TrailingWhitespace
    "             \ term=standout ctermfg=red ctermbg=red guifg=red guibg=red
    au ColorScheme * hi link TrailingWhitespace Error
    au WinNew * let w:trailing_whitespace =
                \ matchadd('TrailingWhitespace', '\s\+$')
aug END
com! TrailingWhitespace
            \ if w:trailing_whitespace
                \|call matchdelete(w:trailing_whitespace)
                \|let w:trailing_whitespace = 0
            \|else
                \|let w:trailing_whitespace =
                    \ matchadd('TrailingWhitespace', '\s\+$')
            \|endif
let g:TrailingWhitespaceExcludedFileTypes = [
            \ 'diff',
            \ 'markdown',
            \ 'fugitive',
            \ 'gitcommit',
            \ 'vim-plug',
            \]
au TrailingWhitespace FileType *
            \ if (index(g:TrailingWhitespaceExcludedFileTypes, &l:filetype) != -1) |
            \ exe 'au TrailingWhitespace BufWinEnter <buffer> TrailingWhitespace' |
            \ endif
" 1}}}
" Colorcolumn customizations {{{1
command! ColorColumnToggle       call ColorColumnToggle(1)
command! ColorColumnToggleGlobal call ColorColumnToggle(0)
fun! ColorColumnToggle(local) "{{{2
    if a:local
        if &l:colorcolumn == ''
            let &l:colorcolumn = '+'.join(range(1,200),',+')
        else
            let &l:colorcolumn = ''
        endif
    else
        if &colorcolumn == ''
            let &colorcolumn = '+'.join(range(1,200),',+')
        else
            let &colorcolumn = ''
        endif
    endif
endfun "2}}}
aug MyCustomColorColumn
    au!
    au BufEnter * if &ft =~ 'gitcommit\|vim'
                \| let &l:colorcolumn = '+'.join(range(1,200),',+')
                \| endif
aug END
" 1}}}
" Terminal quirks {{{1
" Bracketed paste support
if $TERM =~ 'alacritty\|foot\|st-256color'
    let &t_BE = "\<Esc>[?2004h"
    let &t_BD = "\<Esc>[?2004l"
    let &t_PS = "\<Esc>[200~"
    let &t_PE = "\<Esc>[201~"
endif

" Automatic detection of `bg`
if $TERM =~ 'alacritty\|foot'
    let &t_RB = "\<Esc>]11;?\<C-g>"
    let &t_RF = "\<Esc>]10;?\<C-g>"
endif

":h xterm-true-color
if $TERM =~ 'foot\|st-256color'
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
elseif $TERM =~ 'alacritty'
    let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
    let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"
endif

" https://codeberg.org/dnkl/foot/issues/628
" dnkl: Note that foot by default emits escapes that require modifyOtherKeys
"       to be enabled in XTerm. I.e. foot's default doesn't match XTerm's
"       default
":h modifyOtherKeys
if $TERM == 'foot'
    let &t_TI = "\<Esc>[>4;2m"
    let &t_TE = "\<Esc>[>4;m"
endif

" See: https://github.com/kovidgoyal/kitty/issues/108#issuecomment-320492663
"
" Vim hardcodes background color erase even if the terminfo file does not
" contain bce (not to mention that libvte based terminals incorrectly contain
" bce in their terminfo files). This causes incorrect background rendering
" when using a colorscheme with a non-transparent background.
set t_ut=
"1}}}

" neovim-specific config {{{1
if has('nvim')
    unmap Y
    if $TERM =~ 'foot\|alacritty'
        set termguicolors
        au UIEnter * ++once call timer_start(0,
                    \{->execute("colo PaperColor")})
    endif
    if !empty(exepath('python3')) || (!empty(exepath('python')) &&
                \system('python -c "import sys; print(sys.version_info.major)"') ==# '3')
        let s:python3exe = !empty(exepath('python3')) ? exepath('python3') : exepath('python')
        let s:python3venv = '~/.config/nvim/venv'
        if empty(glob(s:python3venv))
            5new | exe 'terminal echo Creating virtualenv... ;'
                        \. s:python3exe . ' -m venv ' . s:python3venv . ';'
                        \. s:python3venv . '/bin/python -m pip install wheel;'
                        \. s:python3venv . '/bin/python -m pip install pynvim;'
            autocmd TermClose <buffer> ++once if v:event.status == 0
                        \| exe "bdelete" . expand("<abuf>") | endif
        endif
        let g:python3_host_prog = expand(s:python3venv . '/bin/python')
        let $PATH = fnamemodify(g:python3_host_prog, ':p:h') . ':' . $PATH
    endif
endif
"1}}}

let s:autoloaddir = expand((!has('nvim') ? '~/.vim' : '~/.config/nvim') . '/autoload')
if !empty(glob(s:autoloaddir . '/plug.vim'))
" Plugins {{{
" -------
aug delayed_plug_load
    au!
aug END
call plug#begin('~/.config/nvim/plugged')
Plug 'wsdjeg/vim-fetch'
Plug 'junegunn/fzf.vim', {'on':[]}
    au delayed_plug_load BufEnter * ++once if exists(':FZF') == 2 |
                \ call timer_start(0, {->plug#load('fzf.vim')}) | endif
Plug 'editorconfig/editorconfig-vim'
    let g:EditorConfig_exclude_patterns = ['^[[:alpha:]]*://.*']
    let g:EditorConfig_exec_path = exepath('editorconfig')
    let g:EditorConfig_core_mode = !empty(g:EditorConfig_exec_path)
                                    \? 'external_command'
                                    \: 'vim_core'

" Language support
Plug 'zah/nim.vim',             {'for': 'nim'}
Plug 'ziglang/zig.vim',         {'for': 'zig'}
Plug 'isobit/vim-caddyfile',    {'for': 'caddyfile'}

" Improve editing experience
Plug 'guns/vim-sexp'            " lisp
Plug 'alvan/vim-closetag'       " html tags
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'subnut/visualstar.vim'
    au delayed_plug_load BufEnter * ++once
                \ call timer_start(0, {->plug#load('visualstar.vim')})
    xmap <leader>* <Plug>(VisualstarSearchReplace)
    nmap <leader>* <Plug>(VisualstarSearchReplace)

" git-related
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim', {'on': 'GV'}        " Commit browser
Plug 'airblade/vim-gitgutter', {'on': []}   " Git diff
    au delayed_plug_load BufEnter * ++once call timer_start(0, {->execute("
                \call plug#load('vim-gitgutter')
                \|silent! doau gitgutter CursorHold")})
    let g:gitgutter_map_keys = 0
    nmap <leader>gp <Plug>(GitGutterPreviewHunk)
    nmap <leader>ga <Plug>(GitGutterStageHunk)
    nmap [g <Plug>(GitGutterPrevHunk)
    nmap ]g <Plug>(GitGutterNextHunk)
    let g:gitgutter_set_sign_backgrounds = 0
    hi GitGutterAdd     ctermfg=2
    hi GitGutterChange  ctermfg=3
    hi GitGutterDelete  ctermfg=1

" snippets
Plug 'hrsh7th/vim-vsnip'
Plug 'rafamadriz/friendly-snippets'
    imap <expr> <Tab>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<Tab>'
    smap <expr> <Tab>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<Tab>'
    imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
    smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" latex
Plug 'lervag/vimtex'
    let g:vimtex_view_method = 'zathura'

" undotree
Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
    let g:undotree_WindowLayout = 2
    let g:undotree_SetFocusWhenToggle = 1
    nnoremap <leader>u <cmd>UndotreeToggle<cr>

" Python auto-formatter
Plug 'psf/black', { 'branch': 'stable', 'on': [] }
    au delayed_plug_load BufEnter * ++once
                \ call timer_start(100, {->plug#load('black')})
    aug Black
        au!
        au BufWritePre * exe (&l:ft == 'python' ? 'Black' : '')
    aug END

" Copy to clipboard using OSC 52 - mapped to <leader>Y
Plug 'ojroques/vim-oscyank'
    let g:oscyank_silent = 1
    noremap <leader>Y "y
    aug oscyank
        au!
        au TextYankPost * if v:event.regname ==# 'y' | OSCYankReg y | endif
    aug END

" Neovim-specific
if has('nvim')
    Plug 'subnut/nvim-ghost.nvim', #{do:':call nvim_ghost#installer#install()'}
    Plug 'windwp/nvim-autopairs'
    Plug 'neovim/nvim-lspconfig'
    Plug 'hrsh7th/nvim-cmp'
        Plug 'hrsh7th/cmp-nvim-lsp'
        Plug 'hrsh7th/cmp-buffer'
        Plug 'hrsh7th/cmp-vsnip'
endif

" Themes
Plug 'cocopon/iceberg.vim'
Plug 'NLKNguyen/papercolor-theme'
    let g:PaperColor_Theme_Options = #{
                \   theme: #{
                \       default: #{
                \           allow_bold: 1,
                \           allow_italic: 1,
                \       }
                \   },
                \   language: #{
                \       c: #{highlight_builtins: 1},
                \       python: #{highlight_builtins: 1},
                \   }
                \}
Plug 'sainnhe/gruvbox-material'
    let g:gruvbox_material_better_performance = 1
    let g:gruvbox_material_sign_column_background = 'none'
    let g:gruvbox_material_background = 'hard'
    let g:gruvbox_material_foreground = 'mix'
    aug gruvbox_material_overrides
        au!
        au ColorScheme gruvbox-material hi CurrentWord
                    \ term=underline cterm=underline gui=underline
    aug END
call plug#end()
else
    echohl WarningMsg
    echom 'vim-plug not installed. plugins not available.'
    echohl None
    if !empty(exepath('curl'))
        echom 'run :PlugInstall to install vim-plug'
        execute("command! PlugInstall execute '!curl -L --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
                \ -o " . s:autoloaddir . "/plug.vim'
                \| source " . expand('<sfile>')
                \. '|PlugInstall'
                \)
    else
        echom 'curl not found. :PlugInstall disabled.'
    endif
endif

" Deprecated plugins {{{2
" ------------------

"" Auto-close brackets (and quotes)
" Plug 'itmammoth/doorboy.vim'    "`' () [] {}
"     let g:doorboy_additional_brackets = #{c:['<>']}

" Plug 'ms-jpq/coq_nvim'
"     let g:coq_settings = {
"                 \ 'auto_start': 'shut-up',
"                 \ 'display.icons.mode': 'none',
"                 \ 'keymap.recommended': v:true,
"                 \ 'completion.always': v:true,
"                 \ 'display.pum.fast_close': v:false,
"                 \ 'limits.completion_auto_timeout': 1,
"                 \}

"" Show diff between swapfile and file on disk
" Plug 'chrisbra/recover.vim'
"     let g:RecoverPlugin_Prompt_Verbose = 1

"" NOTE: Do NOT enable the recover.vim plugin unless ABSOLUTELY necessary.
""       It does some weird things.
"" TODO: Extract out the compare-between-current-and-swapfile functionality
""       into our own separate function, and delete this.
"" TIP: Use v:progname (or v:argv) to invoke this special function. Possible
""      names are - vimswapdiff

"2}}}
"}}}

" vim:et:ts=4:sts=4:sw=0:fdm=marker
