function _zsh-instant-repl_zle-line-init() {
	# call wrapped zle-line-init if it exists
	(( ! ${+widgets[._zsh-instant-repl_orig_zle-line-init]} )) || zle ._zsh-instant-repl_orig_zle-line-init $@
	local ret=$?
	if [[ $CONTEXT = start ]]; then
		LBUFFER=$ZSH_INSTANT_REPL_PREFIX$LBUFFER
	fi
	return $ret
}

function _zsh-instant-repl_set-zle-repl() {
	ZSH_INSTANT_REPL_PREFIX=$LBUFFER
}

# wrap previous zle-line-init if it exists
(( ! ${+widgets[zle-line-init]} )) || zle -A zle-line-init ._zsh-instant-repl_orig_zle-line-init
zle -N zle-line-init _zsh-instant-repl_zle-line-init
zle -N set-zle-repl _zsh-instant-repl_set-zle-repl
