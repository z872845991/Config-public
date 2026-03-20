# ╔══════════════════════════════════════════════════════════════╗
# ║                     FZF Configuration                      ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Default Command (rg) ──────────────────────────────────────
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!{.git,node_modules,.cache,venv,.venv,__pycache__,.mypy_cache}"'

# ── Theme & Appearance ────────────────────────────────────────
export FZF_DEFAULT_OPTS="
  --height=70%
  --layout=reverse
  --border=rounded
  --margin=0,1
  --padding=0,1
  --info=inline-right
  --separator='─'
  --scrollbar='▐'
  --pointer='▶'
  --marker='✓'
  --prompt='  '
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
  --color=border:#585b70,label:#cba6f7,query:#cdd6f4
  --bind='ctrl-j:down,ctrl-k:up'
  --bind='ctrl-d:half-page-down,ctrl-u:half-page-up'
  --bind='ctrl-/:toggle-preview'
  --preview-window='right:55%:border-left:wrap'
  --preview='[[ -d {} ]] && eza --color=always --icons -T -L 2 {} 2>/dev/null || bat --color=always --style=numbers,changes --line-range=:300 {} 2>/dev/null || cat {}'
"

export FZF_COMPLETION_TRIGGER='\'
export FZF_COMPLETION_OPTS='--border --info=inline'
export FZF_COMPLETION_PATH_OPTS='--walker file,dir,follow,hidden'
export FZF_COMPLETION_DIR_OPTS='--walker dir,follow'
export FZF_TMUX=1
export FZF_TMUX_HEIGHT='80%'

# ── Autoload fzf functions ────────────────────────────────────
_fzf_fpath=${0:h}/fzf
fpath+=$_fzf_fpath
autoload -U $_fzf_fpath/*(.:t)
unset _fzf_fpath

# ╔══════════════════════════════════════════════════════════════╗
# ║                      ZLE Widgets                           ║
# ╚══════════════════════════════════════════════════════════════╝

fzf-redraw-prompt() {
	local precmd
	for precmd in $precmd_functions; do
		$precmd
	done
	zle reset-prompt
}
zle -N fzf-redraw-prompt

# from ~/.fzf/shell/key-bindings.zsh
bindkey '^p' fzf-file-widget
bindkey '^t' fzf-cd-widget

# ╔══════════════════════════════════════════════════════════════╗
# ║                   Search Functions                         ║
# ╚══════════════════════════════════════════════════════════════╝

# ── fif: Find In File (rg + fzf + bat preview) ───────────────
# Usage: fif <pattern> [rg options]
fif() {
	if [[ $# -eq 0 ]]; then
		echo "Usage: fif <pattern> [rg options]"
		return 1
	fi
	local pattern=$1; shift
	rg --files-with-matches --no-messages --hidden --follow \
		--glob '!{.git,node_modules,.cache}' "$pattern" "$@" |
	fzf --preview "bat --color=always --style=numbers,changes {} 2>/dev/null |
		rg --colors 'match:bg:yellow' --ignore-case --pretty --context 5 '$pattern' ||
		rg --ignore-case --pretty --context 5 '$pattern' {}" \
		--preview-window='right:60%:border-left:wrap'
}

# ── find-in-file: Live grep with rg ──────────────────────────
# Ctrl-F: interactive ripgrep search with live preview
find-in-file() {
	local result
	result=$(rg --color=always --line-number --no-heading --smart-case "" 2>/dev/null |
		fzf --ansi --delimiter=: \
			--preview 'bat --color=always --style=numbers,changes --highlight-line {2} {1} 2>/dev/null' \
			--preview-window='right:60%:border-left:+{2}-5:wrap' \
			--header='  Ctrl-F: search in files')
	if [[ -n $result ]]; then
		local file line
		file=$(echo "$result" | cut -d: -f1)
		line=$(echo "$result" | cut -d: -f2)
		LBUFFER="${EDITOR:-vim} +${line} ${(q)file}"
	fi
	zle reset-prompt
}
zle -N find-in-file
bindkey '^f' find-in-file

# ╔══════════════════════════════════════════════════════════════╗
# ║              Pacman / AUR Helper Functions                 ║
# ╚══════════════════════════════════════════════════════════════╝

# ── pac-install: Search & install packages (pacman + AUR) ─────
# Usage: pac-install [query]
pac-install() {
	local cache_dir="/tmp/pac-fzf-$USER"
	mkdir -p "$cache_dir"
	local list_cache="$cache_dir/pkg-list"

	# Refresh cache if older than 1 hour or forced with -y
	if [[ $1 == "-y" ]]; then
		rm -f "$list_cache"
		shift
	fi
	if [[ ! -f "$list_cache" ]] || (( $(date +%s) - $(stat -c %Y "$list_cache" 2>/dev/null || echo 0) > 3600 )); then
		{ pacman --color=always -Sl; paru --color=always -Sl aur } 2>/dev/null |
			sed 's/ [^ ]*unknown-version[^ ]*//' > "$list_cache"
	fi

	local pkg
	pkg=$(cat "$list_cache" |
		awk '{print $2"\t"$1"/"$3}' |
		fzf --ansi -m -q "${1:-}" \
			--header='  pac-install: Tab=select, Enter=install' \
			--preview 'paru --color=always -Si {1} 2>/dev/null' \
			--preview-window='right:55%:border-left:wrap' |
		awk '{print $1}' | xargs)

	if [[ -n $pkg ]]; then
		echo "Installing: $pkg"
		local cmd="paru -S $pkg"
		print -s "$cmd"
		eval "$cmd"
		rehash
	fi
}

# ── pac-remove: Search & remove installed packages ────────────
# Usage: pac-remove [query]
#   -e  only explicitly installed packages
pac-remove() {
	local query_opts=()
	if [[ $1 == "-e" ]]; then
		query_opts+=("-e")
		shift
	fi

	local pkg
	pkg=$(paru --color=always -Q "${query_opts[@]}" 2>/dev/null |
		fzf --ansi -m -q "${1:-}" \
			--header='  pac-remove: Tab=select, Enter=remove' \
			--preview 'paru --color=always -Qi {1} 2>/dev/null' \
			--preview-window='right:55%:border-left:wrap' |
		awk '{print $1}' | xargs)

	if [[ -n $pkg ]]; then
		echo "Removing: $pkg"
		local cmd="paru -Rns $pkg"
		print -s "$cmd"
		eval "$cmd"
	fi
}

# ── pac-search: Search packages with detailed info ────────────
# Usage: pac-search [query]
pac-search() {
	paru --color=always -Ss "${1:-}" 2>/dev/null |
		fzf --ansi -m \
			--header='  pac-search: browse packages' \
			--preview 'paru --color=always -Si {1} 2>/dev/null' \
			--preview-window='right:55%:border-left:wrap'
}

# ── pac-browse: Browse installed packages with file list ──────
# Usage: pac-browse [query]
pac-browse() {
	local pkg
	pkg=$(paru --color=always -Q 2>/dev/null |
		fzf --ansi -q "${1:-}" \
			--header='  pac-browse: Enter=show files' \
			--preview 'paru --color=always -Qi {1} 2>/dev/null' \
			--preview-window='right:55%:border-left:wrap' |
		awk '{print $1}')

	if [[ -n $pkg ]]; then
		pacman -Ql "$pkg" |
			awk '{print $2}' |
			fzf --header="  Files in: $pkg" \
				--preview 'bat --color=always --style=numbers {} 2>/dev/null || file {}' \
				--preview-window='right:60%:border-left:wrap'
	fi
}
