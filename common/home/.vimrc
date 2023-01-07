scriptencoding utf-8
unlet! skip_defaults_vim
if !has("nvim")
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
setg matchpairs+=<:>
setg listchars=trail:-,nbsp:+

setg listchars+=eol:~
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


" :Notab -- :retab, but with 'expandtab' set {{{
com! -range -bang Notab let b:Notab_et = &l:et | let &l:et = 1 | exe
            \ (<range>?(<range>-1)?"<line1>,<line2>":"<line1>":"")."retab"
            \."<bang>" | let &l:et = b:Notab_et | unlet b:Notab_et
" }}}
" Swap files {{{
let s:swapdir = !has("nvim") ? '~/.vimswap' : '~/.config/nvim/swap'
if !isdirectory(fnamemodify(s:swapdir, ':p'))
    if exists('*mkdir')
        call mkdir(fnamemodify(s:swapdir, ':p'), 'p', 0o0700)
        if !isdirectory(fnamemodify(s:swapdir, ':p'))
            let &directory = s:swapdir . "//"
        endif
    else
        echohl WarningMsg
        echom 'Please create ' . s:swapdir . ' directory with with permissions 0700'
        echohl None
    endif
else
    let &directory = s:swapdir . "//"
    if getfperm(fnamemodify(s:swapdir, ':p')) !=# 'rwx------'
        call setfperm(fnamemodify(s:swapdir, ':p'), 'rwx------')
    endif
endif
" }}}
" Persistent undo {{{
let s:undodir = !has("nvim") ? '~/.vimundo' : '~/.config/nvim/undo'
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
" }}}
" Delete surrounding (ds) {{{
nnoremap <silent><expr> ds 'di' . nr2char(getchar()) . 'vhp'
" }}}
" Ranger integration {{{
if exists('$RANGER_LEVEL')
    nmap q <cmd>q<CR>
endif "}}}
" GetHiGroup - Get higlight group of the character under cursor {{{
fun! GetHiGroup()
    return synIDattr(synID(line('.'), col('.'), 1), 'name')
endfun
command! GetHiGroup echo GetHiGroup()
"}}}
" Show Trailing Spaces {{{
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
            \]
au TrailingWhitespace FileType *
            \ if (index(g:TrailingWhitespaceExcludedFileTypes, &l:filetype) != -1) |
            \ exe 'au TrailingWhitespace BufWinEnter <buffer> TrailingWhitespace' |
            \ endif
" }}}
" Colorcolumn customizations {{{
command! ColorColumnToggle       call ColorColumnToggle(1)
command! ColorColumnToggleGlobal call ColorColumnToggle(0)
fun! ColorColumnToggle(local) "{{{
    if a:local
        if &l:colorcolumn == ''
            let &l:colorcolumn = '+'.join(range(1,100),',+')
        else
            let &l:colorcolumn = ''
        endif
    else
        if &colorcolumn == ''
            let &colorcolumn = '+'.join(range(1,100),',+')
        else
            let &colorcolumn = ''
        endif
    endif
endfun "}}}
aug MyCustomColorColumn
    au!
    au BufEnter * if &ft =~ 'gitcommit\|vim'
                \| let &l:colorcolumn = '+'.join(range(1,100),',+')
                \| endif
aug END
" }}}
" My Commentor {{{
map gc <Plug>(MyCommentor)
map gcc gcl

" map gcc <Plug>(My-Commenter)
" map gcu <Plug>(My-Un-Commenter)
map gct <Plug>(My-Comment-Toggler)

" Implementation {{{
fun! MyCommenterHelper() "{{{
    " if comments like #python
    if &l:cms =~ '\v^.*\%s$'
        " - Goto start of last selection
        " - Restart last selection
        " - Switch to Visual-Block mode
        " - Insert the cms at the front of each line
        " The printf is added to input an extra space between the cms and the
        " commented text, just to look nice.
        execute 'normal! `<gv' . "\<C-V>" . 'I'
                    \. printf(&l:cms, &l:cms =~'\V\s%s' ? '' : ' ')

    " if comments like /* CSS */
    elseif &l:cms =~ '\v^.*\%s.*$'
        " First compute the cms, with nice-to-look spaces added between
        " comment characters and commented text
        let l:cms = '\1' . printf(&l:cms,
                    \(&l:cms =~ '\V\s%s' ? '' : ' ')
                    \. '\2'
                    \. (&l:cms =~ '\V%s\s' ? '' : ' '))
        " Then do the actual commenting, line-by-line
        for line in range(line("'<"), line("'>"))
            call setline(line, substitute(
                            \getline(line), '\v^(\s*)(.{-})$', l:cms, ''
                            \)
                        \)
        endfor
    endif
endfun! "}}}
nmap <Plug>(My-Commenter) V<Plug>(My-Commenter)
vmap <Plug>(My-Commenter) <ESC><cmd>silent! call MyCommenterHelper()<CR>
fun! MyUnCommenterHelper() "{{{
    let l:saved = @/
    let @/ = '\v^(\s{-})\V'
    if &l:cms =~ '\v^.*\%s$'
        let @/ .= escape(printf(&l:cms, '\v {,1}(.*)'), '/')
    elseif &l:cms =~ '\v^.*\%s.*$'
        let @/ .= escape(printf(&l:cms,'\v {,1}(.{-}) {,1}\V'),'/')
    endif
    execute 'normal! ' . ":'<,'>" . 's//\1\2/g' . "\<CR>"
    let @/ = l:saved
endfun! "}}}
nmap <Plug>(My-Un-Commenter) V<Plug>(My-Un-Commenter)
vmap <Plug>(My-Un-Commenter) <ESC><cmd>silent! call MyUnCommenterHelper()<CR>

fun! MyCommentTogglerOpFunc(...) "{{{
    for line in range(line("'["), line("']"))
        if getline(line) =~ ('\v^\s{-}\V' .  printf(&l:cms,'\.\*'))
            execute 'normal ' . line . "GV\<Plug>(My-Un-Commenter)"
        else
            execute 'normal ' . line . "GV\<Plug>(My-Commenter)"
        endif
    endfor
    let &opfunc = get(g:,'MyCommentToggler_saved_opfunc','')
    silent! unlet g:MyCommentToggler_saved_opfunc
endfun "}}}
nmap <Plug>(My-Comment-Toggler) 
            \<cmd>let g:MyCommentToggler_saved_opfunc=&opfunc<CR>
            \<cmd>setl opfunc=MyCommentTogglerOpFunc<CR>g@
vmap <Plug>(My-Comment-Toggler) <ESC>'<<Plug>(My-Comment-Toggler)'>

fun! MyCommentorOpFunc(...) "{{{
    if empty(&l:cms) | return | endif " if commentstring is empty, abort
    if getline(line("'[")) =~ ('\v^\s{-}\V' .  printf(&l:cms,'\.\*'))
        execute "normal '[V']\<Plug>(My-Un-Commenter)"
    else
        execute "normal '[V']\<Plug>(My-Commenter)"
    endif
    let &opfunc = get(g:,'MyCommentor_saved_opfunc','')
    silent! unlet g:MyCommentor_saved_opfunc
endfun "}}}
nmap <Plug>(MyCommentor) 
            \<cmd>let g:MyCommentor_saved_opfunc=&opfunc<CR>
            \<cmd>setl opfunc=MyCommentorOpFunc<CR>g@
vmap <Plug>(MyCommentor) <ESC>'<<Plug>(MyCommentor)'>
"}}}
"}}}
" Copy to clipboard {{{
if !(has('xterm_clipboard') && has('unnamedplus')) " use <leader>y
    noremap <leader>y <cmd>call SyncClipboard()<CR>"z
    aug YankToClipboard
        au!
        au TextYankPost * if v:event.regname ==# 'z' | call CopyToClipboard(
                    \join(v:event.regcontents, "\n"))| endif
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
" }}}
" Terminal quirks {{{
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
"}}}

let s:autoloaddir = (!has("nvim") ? '~/.vim' : '~/.config/nvim') .. '/autoload'
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

" language support
Plug 'zah/nim.vim',             {'for': 'nim'}
Plug 'ziglang/zig.vim',         {'for': 'zig'}
Plug 'isobit/vim-caddyfile',    {'for': 'caddyfile'}

" Improve editing experience
Plug 'guns/vim-sexp'            " lisp
Plug 'alvan/vim-closetag'       " html tags
Plug 'tpope/vim-surround'
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

" undotree
Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
    let g:undotree_WindowLayout = 2
    let g:undotree_SetFocusWhenToggle = 1
    nnoremap <leader>u <cmd>UndotreeToggle<cr>

" python auto-formatter
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
    noremap  <leader>Y "y
    aug oscyank
        au!
        au TextYankPost * if v:event.regname ==# 'y' | OSCYankReg y | endif
    aug END

" themes
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
                \       c: #{highlight_builtins:1},
                \       python: #{highlight_builtins:1},
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


if $TERM =~ 'st-256color'
    set termguicolors
    colorscheme gruvbox-material
endif


" See: https://github.com/kovidgoyal/kitty/issues/108#issuecomment-320492663
"
" Vim hardcodes background color erase even if the terminfo file does not
" contain bce (not to mention that libvte based terminals incorrectly contain
" bce in their terminfo files). This causes incorrect background rendering
" when using a colorscheme with a non-transparent background.
set t_ut=


" vim:et:ts=4:sts=4:sw=0:fdm=marker
