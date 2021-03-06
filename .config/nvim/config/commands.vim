" ┏━┓┏━┓┏┏┓┏┏┓┳━┓┏┓┓┳━┓┓━┓
" ┃  ┃ ┃┃┃┃ ┃┃┃ ┃━┫┃┃┃┃ ┃┗━┓
" ┗━┛┛━┛┛ ┇┛ ┇┛ ┇┇┗┛┇━┛━━┛

" Switch to normal mode
" inoremap jk <esc>

" when line overflows, it will go
" one _visual_ line and not actual
" nnoremap j gj
" nnoremap k gk
" vnoremap j gj
" vnoremap k gk

" tab managment in case you're one of the psychos that use tabs
" map <C-o> :tabnew<cr>
" map <C-c> :tabclose<cr>
" nnoremap <Leader>k gT
" nnoremap <Leader>j gt

" spell-check (English US and Brazilian Portuguese)
map <F6> :setlocal spell! spelllang=en_us<cr>
map <F7> :setlocal spell! spelllang=pt_br<cr>

" buffer managment
nnoremap <Leader>bn :bnext<cr>
nnoremap <Leader>bp :bprev<cr>

" split Managment
nnoremap <C-Down> <C-w><C-j>
nnoremap <C-Up> <C-w><C-k>
nnoremap <C-Right> <C-w><C-l>
nnoremap <C-Left> <C-w><C-h>

" disable hlsearch
map <C-s> :noh<cr>

" go to last change
" nnoremap <Leader>l :'.<cr>

" replace all is aliased to S.
nnoremap S :%s//g<Left><Left>

" save file as sudo on files that require root permission
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" execute file
nnoremap <leader>x :!chmod +x % && ./%<cr>

" check file in shellcheck:
"noremap <leader>s :!clear && shellcheck %<cr>
noremap <leader>s :sp \| terminal shellcheck %<cr>

fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
augroup BufferWrite
	au!
	" automatically deletes all trailing whitespace on save.
    autocmd BufWritePre * :call TrimWhitespace()
	" when shortcut files are updated, renew bash and ranger configs with new material:
	autocmd BufWritePost files,directories !shortcuts
	" run xrdb whenever Xdefaults or Xresources are updated.
	autocmd BufWritePost *Xresources,*Xdefaults !xrdb %
	" update binds when sxhkdrc is updated.
	autocmd BufWritePost *sxhkdrc !pkill -USR1 sxhkd
	" reload vim when configuration is updated
	" autocmd BufWritePost init.vim,general.vim,commands.vim,ui.vim,term.vim,statusline.vim,plugin.vim,plugin-settings.vim source $MYVIMRC
augroup end

" open terminal
noremap <Leader>ot :split term://bash<cr>:resize 10<cr>

" exit from terminal mode
tnoremap <C-e> <C-\><C-n>

" open netrw
nmap <silent><C-n> :Lexplore<cr>

" ignore
let g:netrw_list_hide= '.*\.swp$,*/tmp/*,*.so,*.swp,*.zip,*.git,^\.\=/\=$'

" open netrw if no files were specified
" augroup OpenNetrw
" 	au!
" 	autocmd StdinReadPre * let s:std_in=1
" 	autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | Lexplore | endif
" 	" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | CHADopen | endif
" augroup end

" close netrw if it's the only buffer open
augroup finalcountdown
  au!
  autocmd WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&filetype") == "netrw" || &buftype == 'quickfix' |q|endif
augroup END

" netrw settings
let g:netrw_banner = 0
let g:netrw_liststyle = 4
let g:netrw_browse_split = 0
let g:netrw_winsize = 20

function! NetrwMappings()
    " Hack fix to make ctrl-l work properly
    noremap <buffer> <C-l> <C-w>l
endfunction

augroup netrw_mappings
    autocmd!
    autocmd filetype netrw call NetrwMappings()
augroup END

" restore cursor position
function! ResCur()
  if line("'\"") <= line('$')
    normal! g`"
    return 1
  endif
endfunction
augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

" " toggle statusbar
" let s:hidden_all = 0
" function! ToggleHiddenAll()
" 	if s:hidden_all  == 0
" 		let s:hidden_all = 1
" 		set laststatus=1
" 		set noruler
" 		set noshowcmd
" 		set showmode
" 	else
" 		let s:hidden_all = 0
" 		set laststatus=2
" 		set noruler
" 		set noshowcmd
" 		set noshowmode
" 	endif
" endfunction

" nnoremap <S-T> :call ToggleHiddenAll()<cr>

" auto pair
let s:pair = 1
function! ToggleAutoPair()
	if s:pair == 1
		let s:pair = 0
		inoremap { {}<esc>ha
		inoremap ( ()<esc>ha
		inoremap ` ``<esc>ha
		inoremap ' ''<esc>ha
		inoremap " ""<esc>ha
	else
		let s:pair = 1
		iunmap {
		iunmap (
		iunmap `
		iunmap '
		iunmap "
	endif
endfunction
call ToggleAutoPair()
nnoremap <Leader>p :call ToggleAutoPair()<cr>


" identify the syntax highlighting group
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<cr>

" turns off highlighting on the bits of code that are changed, so the line that is changed is highlighted but the actual text that has changed stands out on the line and is readable.
if &diff
	hi DiffAdd      ctermbg=NONE   ctermfg=2      cterm=NONE
	hi DiffDelete   ctermbg=NONE   ctermfg=1      cterm=NONE
	hi DiffChange   ctermbg=NONE   ctermfg=3      cterm=NONE
	hi DiffText     ctermbg=NONE   ctermfg=7      cterm=NONE
endif

" Use D to show documentation in preview window
"nnoremap <silent><C-d> :call <SID>show_documentation()<CR>

" abbreviations
" iab @@ luishenriquegh2701@gmail.com
" map <leader>t :r ~/.local/share/template<cr>

" Quickfix and location (window-local) lists
let g:luishgh_qf_l = 0
let g:luishgh_qf_g = 0

function! ToggleLists(global)
    if a:global
        if g:luishgh_qf_g == 1
            let g:luishgh_qf_g = 0
            cclose
        else
            let g:luishgh_qf_g = 1
            copen
        end
    else
        if g:luishgh_qf_l == 1
            let g:luishgh_qf_l = 0
             lclose
        else
            let g:luishgh_qf_l = 1
             lopen
        end
    end
endfun

nnoremap <C-q> <cmd>call ToggleLists(1)<CR>
nnoremap <C-j> <cmd>cnext<CR>zz
nnoremap <C-k> <cmd>cprev<CR>zz

nnoremap <leader>q <cmd>call ToggleLists(0)<CR>
nnoremap <leader>j <cmd>lnext<CR>zz
nnoremap <leader>k <cmd>lprev<CR>zz
