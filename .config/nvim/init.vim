set number

set relativenumber
set autoindent
set tabstop=4
set shiftwidth=4
set smarttab
set softtabstop=4
set mouse=a
set modifiable
set encoding=UTF-8

""""fold function
filetype plugin indent on
syntax on
autocmd Filetype * AnyFoldActivate 
" set foldenable
set foldlevel=99
" set foldmethod=indent


"""" undodir
set undodir=$HOME/.local/.nvim_redo
set undofile


"""" plug 
call plug#begin()

Plug 'http://github.com/tpope/vim-surround' " Surrounding ysw)
Plug 'https://github.com/preservim/nerdtree' " NerdTree
Plug 'https://github.com/tpope/vim-commentary' " For Commenting gcc & gc
Plug 'https://github.com/vim-airline/vim-airline' " Status bar
Plug 'https://github.com/lifepillar/pgsql.vim' " PSQL Pluging needs :SQLSetType pgsql.vim
Plug 'https://github.com/ap/vim-css-color' " CSS Color Preview
Plug 'https://github.com/rafi/awesome-vim-colorschemes' " Retro Scheme
Plug 'https://github.com/tribela/vim-transparent'
" Plug 'https://github.com/neoclide/coc.nvim'  " Auto Completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'https://github.com/ryanoasis/vim-devicons' " Developer Icons
Plug 'https://github.com/tc50cal/vim-terminal' " Vim Terminal
Plug 'https://github.com/preservim/tagbar' " Tagbar for code navigation
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'https://github.com/lambdalisue/suda.vim/' " Sudo
Plug 'https://github.com/gcmt/wildfire.vim'
Plug 'https://github.com/wookayin/semshi'
Plug 'https://github.com/mbbill/undotree'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
Plug 'dhruvasagar/vim-table-mode'
Plug 'dracula/vim',{'name':'dracula'}
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'vim-autoformat/vim-autoformat'
Plug 'mzlogin/vim-markdown-toc'
Plug 'pseewald/vim-anyfold'
Plug 'jiangmiao/auto-pairs'  " auto pairs () [] ,etc
Plug 'ianding1/leetcode.vim'
Plug 'Yggdroot/indentLine'  " Add indent line for code
" Plug 'Corona09/picgo.nvim'
Plug 'jspringyc/vim-word'
Plug 'github/copilot.vim'
Plug 'chrisbra/csv.vim'
Plug 'kdheepak/lazygit.nvim' 
Plug 'puremourning/vimspector'
Plug 'kevinhwang91/rnvimr'
Plug 'mg979/vim-xtabline'
" Plug 'pappasam/coc-pyright', { 'do': 'yarn install --frozen-lockfile && yarn build', 'branch': 'main' }
" Plug 'clangd/coc-clangd', {'do': 'yarn install --frozen-lockfile'}
"Plug 'tmhedberg/SimpylFold', { 'for' :['python', 'vim-plug'] }

call plug#end()

" ==================== xtabline ====================
let g:xtabline_settings = {}
let g:xtabline_settings.buffers_paths = 0
" let g:xtabline_settings.current_tab_paths = 2
" let g:xtabline_settings.other_tabs_paths = 0
let g:xtabline_settings.enable_mappings = 0
let g:xtabline_settings.tabline_modes = ['buffers']
let g:xtabline_settings.enable_persistance = 0
let g:xtabline_settings.last_open_first = 0
let g:xtabline_settings.theme = 'dracula'
let g:xtabline_settings.show_right_corner = 0
" noremap to :XTabCycleMode<CR>
noremap \p :echo expand('%:p')<CR>
let g:xtabline_settings.indicators = {
	\ 'modified': '[+]',
	\ 'pinned': '[📌]',
	\}
let g:xtabline_settings.icons = {
	\'pin': '📌',
	\'star': '★',
	\'book': '📖',
	\'lock': '🔒',
	\'hammer': '🔨',
	\'tick': '✔',
	\'cross': '✖',
	\'warning': '⚠',
	\'menu': '☰',
	\'apple': '🍎',
	\'linux': '🐧',
	\'windows': '⌘',
	\'git': '',
	\'palette': '🎨',
	\'lens': '🔍',
	\'flag': '🏁',
	\}

"""""" rnvimr ranger in nvim

" Make Ranger replace Netrw and be the file explorer
let g:rnvimr_enable_ex = 1

" Make Ranger to be hidden after picking a file
let g:rnvimr_enable_picker = 1

" Replace `$EDITOR` candidate with this command to open the selected file
let g:rnvimr_edit_cmd = 'drop'

" Disable a border for floating window
let g:rnvimr_draw_border = 0

" Hide the files included in gitignore
let g:rnvimr_hide_gitignore = 1

" Change the border's color
let g:rnvimr_border_attr = {'fg': 14, 'bg': -1}

" Make Neovim wipe the buffers corresponding to the files deleted by Ranger
let g:rnvimr_enable_bw = 1

" Add a shadow window, value is equal to 100 will disable shadow
let g:rnvimr_shadow_winblend = 70

" Draw border with both
let g:rnvimr_ranger_cmd = ['ranger', '--cmd=set draw_borders both']

" Link CursorLine into RnvimrNormal highlight in the Floating window
highlight link RnvimrNormal CursorLine

nnoremap <silent> <M-o> :RnvimrToggle<CR>
tnoremap <silent> <M-o> <C-\><C-n>:RnvimrToggle<CR>

" Resize floating window by all preset layouts
tnoremap <silent> <M-i> <C-\><C-n>:RnvimrResize<CR>

" Resize floating window by special preset layouts
tnoremap <silent> <M-l> <C-\><C-n>:RnvimrResize 1,8,9,11,5<CR>

" Resize floating window by single preset layout
tnoremap <silent> <M-y> <C-\><C-n>:RnvimrResize 6<CR>

" Map Rnvimr action
let g:rnvimr_action = {
            \ '<C-t>': 'NvimEdit tabedit',
            \ '<C-x>': 'NvimEdit split',
            \ '<C-v>': 'NvimEdit vsplit',
            \ 'gw': 'JumpNvimCwd',
            \ 'yw': 'EmitRangerCwd'
            \ }

" Add views for Ranger to adapt the size of floating window
let g:rnvimr_ranger_views = [
            \ {'minwidth': 90, 'ratio': []},
            \ {'minwidth': 50, 'maxwidth': 89, 'ratio': [1,1]},
            \ {'maxwidth': 49, 'ratio': [1]}
            \ ]

" Customize the initial layout
let g:rnvimr_layout = {
            \ 'relative': 'editor',
            \ 'width': float2nr(round(0.7 * &columns)),
            \ 'height': float2nr(round(0.7 * &lines)),
            \ 'col': float2nr(round(0.15 * &columns)),
            \ 'row': float2nr(round(0.15 * &lines)),
            \ 'style': 'minimal'
            \ }

" Customize multiple preset layouts
" '{}' represents the initial layout
let g:rnvimr_presets = [
            \ {'width': 0.600, 'height': 0.600},
            \ {},
            \ {'width': 0.800, 'height': 0.800},
            \ {'width': 0.950, 'height': 0.950},
            \ {'width': 0.500, 'height': 0.500, 'col': 0, 'row': 0},
            \ {'width': 0.500, 'height': 0.500, 'col': 0, 'row': 0.5},
            \ {'width': 0.500, 'height': 0.500, 'col': 0.5, 'row': 0},
            \ {'width': 0.500, 'height': 0.500, 'col': 0.5, 'row': 0.5},
            \ {'width': 0.500, 'height': 1.000, 'col': 0, 'row': 0},
            \ {'width': 0.500, 'height': 1.000, 'col': 0.5, 'row': 0},
            \ {'width': 1.000, 'height': 0.500, 'col': 0, 'row': 0},
            \ {'width': 1.000, 'height': 0.500, 'col': 0, 'row': 0.5}
            \ ]

" Fullscreen for initial layout
" let g:rnvimr_layout = {
"            \ 'relative': 'editor',
"            \ 'width': &columns,
"            \ 'height': &lines - 2,
"            \ 'col': 0,
"            \ 'row': 0,
"            \ 'style': 'minimal'
"            \ }
"
" Only use initial preset layout
" let g:rnvimr_presets = [{}]


"""""" vimspector
" mnemonic 'di' = 'debug inspect' (pick your own, if you prefer!)
"
" " for normal mode - the word under the cursor
nmap <Leader>di <Plug>VimspectorBalloonEval
" " for visual mode, the visually selected text
xmap <Leader>di <Plug>VimspectorBalloonEval

"""""" lazygit
let g:lazygit_floating_window_winblend = 0 " transparency of floating window
let g:lazygit_floating_window_scaling_factor = 0.9 " scaling factor for floating window
let g:lazygit_floating_window_border_chars = ['╭','─', '╮', '│', '╯','─', '╰', '│'] " customize lazygit popup window border characters
let g:lazygit_floating_window_use_plenary = 0 " use plenary.nvim to manage floating window if available
let g:lazygit_use_neovim_remote = 1 " fallback to 0 if neovim-remote is not installed

let g:lazygit_use_custom_config_file_path = 0 " config file path is evaluated if this value is 1
let g:lazygit_config_file_path = '' " custom config file path
" OR
let g:lazygit_config_file_path = [] " list of custom config file paths




"""""""" indent line
let g:indentLine_enabled = 1
let g:indentLine_char = '¦' 

let g:indentLine_conceallevel = 2

"""""""" markdown preview
function OpenMarkdownPreview (url)
	execute "silent ! google-chrome-stable " . a:url
endfunction
let g:mkdp_browserfunc = 'OpenMarkdownPreview'

""""""""

"""""" coc-extensions
let g:coc_global_extensions = [
      \'coc-translator',
      \'coc-json' 
      \]

"""""  use t as prefix letter 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap tm :MarkdownPreviewToggle<CR> 
nnoremap tt :TableModeToggle<CR>
nnoremap tu :UndotreeToggle<CR>
nnoremap ta :Autoformat<CR>
nmap t8 :TagbarToggle<CR>
nmap ts <Plug>(coc-translator-p)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""map for buffer
map tn :bnext<cr>
map tp :bprevious<cr>
map td :bdelete<cr>  


""""  some shortcut
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-l> :call CocActionAsync('jumpDefinition')<CR>

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)


"""" colorscheme
:set completeopt-=preview " For No Previews
:colorscheme jellybeans
" :colorscheme dracula

let g:NERDTreeDirArrowExpandable="+"
let g:NERDTreeDirArrowCollapsible="~"


"""""" airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline#extensions#whitespace#enabled = 0

if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''
"
" let g:airline_left_sep = 'î°'
" let g:airline_left_alt_sep = 'î±'
" let g:airline_right_sep = 'î²'
" let g:airline_right_alt_sep = 'î³'
" let g:airline_symbols.branch = 'î '
" let g:airline_symbols.readonly = 'î¢'
" let g:airline_symbols.linenr = 'î¡'

"""" anyfold

let g:anyfold_fold_comments = 1

""" SimpylFold config
" let g:SimpylFold_docstring_preview = 1
" let g:SimpylFold_fold_docstring = 1
" let b:SimpylFold_fold_docstring = 1
" let g:SimpylFold_fold_import = 1
" let b:SimpylFold_fold_import = 1
" let g:SimpylFold_fold_blank = 0
" let b:SimpylFold_fold_blank = 0
"""""

""""" leetcode 
let g:leetcode_china = 1
let g:leetcode_solution_filetype = 'cpp'
let g:leetcode_browser = 'chrome'
""""""""

"""""""" copy from pdf 
""""""""

""""""""picgo
nnoremap  <leader>ps :UploadImageFromClipboard<CR> 
let g:picgo#image_code_template = [ '![]( ${url} )' ]

""""""""  c-j to add a line 
nnoremap <C-j> :set paste<CR>o<Esc>:set nopaste<CR>


"""""""""" Auto Completion
inoremap <expr> <Tab> pumvisible() ? coc#_select_confirm() : "<Tab>"
function! CheckBackspace() abort
	let col = col('.') -1
	return !col || getline('.')[col - 1] =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
			\ coc#pum#visible() ? coc#pum#next(1):
			\ CheckBackspace() ? "\<Tab>" :
			\ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR>
			\ coc#pum#visible() ? coc#_select_confirm() :
			\ "\<CR>"
" inoremap <silent><expr> <C-j>
" 			\ coc#pum#visible() ? coc#_select_confirm() :
" 			\ "\<C-j>"
" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
	autocmd!
	" Setup formatexpr specified filetype(s)
	autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
	" Update signature help on jump placeholder
	autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
	nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
	nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
	inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
	inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
	vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
	vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges
" Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics
" nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" " Manage extensions
" nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" " Show commands
" nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" " Find symbol of current document
" nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" " Search workspace symbols
" nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" " Do default action for next item
" nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" " Do default action for previous item
" nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" " Resume latest coc list
" nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

augroup fish_syntax
	au!
	autocmd BufNewFile,BufRead *.fish set syntax=sh
augroup end

hi String ctermfg=076
hi Number ctermfg=076

