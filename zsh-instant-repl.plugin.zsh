function _zsh-instant-repl_zle-line-init() {
	# call wrapped zle-line-init if it exists
	(( ! ${+widgets[._zsh-instant-repl_orig_zle-line-init]} )) || zle ._zsh-instant-repl_orig_zle-line-init $@
	local ret=$?
	if [[ $CONTEXT = start ]]; then
		LBUFFER=$INSTANT_REPL_PREFIX$LBUFFER
	fi
	return $ret
}
# wrap previous zle-line-init if it exists
(( ! ${+widgets[zle-line-init]} )) || zle -A zle-line-init ._zsh-instant-repl_orig_zle-line-init
zle -N zle-line-init _zsh-instant-repl_zle-line-init

function _zsh-instant-repl_repl-set() {
	INSTANT_REPL_PREFIX=$LBUFFER
}
zle -N repl-set _zsh-instant-repl_repl-set
