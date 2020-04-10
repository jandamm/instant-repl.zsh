function _zsh-instant-repl_set-buffer() {
	LBUFFER=$INSTANT_REPL_PREFIX$LBUFFER
}

function _zsh-instant-repl_zle-line-init() {
	# call wrapped zle-line-init if it exists
	(( ! ${+widgets[._zsh-instant-repl_orig_zle-line-init]} )) || zle ._zsh-instant-repl_orig_zle-line-init $@
	local ret=$?
	if [[ $CONTEXT = start ]]; then
		_zsh-instant-repl_set-buffer
	fi
	return $ret
}
# wrap previous zle-line-init if it exists
(( ! ${+widgets[zle-line-init]} )) || zle -A zle-line-init ._zsh-instant-repl_orig_zle-line-init
zle -N zle-line-init _zsh-instant-repl_zle-line-init

function _zsh-instant-repl_repl-set() {
	if [ -n "$INSTANT_REPL_NO_AUTOFIX" ]; then
		INSTANT_REPL_PREFIX=$LBUFFER
	else
		INSTANT_REPL_PREFIX="$(echo $LBUFFER | sed 's/ *$//') "
	fi
}
zle -N repl-set _zsh-instant-repl_repl-set

function _zsh-instant-repl_repl-clear() {
	INSTANT_REPL_PREFIX=
}
zle -N repl-clear _zsh-instant-repl_repl-clear

function _zsh-instant-repl_kill-whole-line() {
	if [ "$LBUFFER" = "$INSTANT_REPL_PREFIX" ] \
		|| ([ -z "$LBUFFER" ] && [ -z "$INSTANT_REPL_TOGGLE_KILL_LINE" ]); then
		zle kill-whole-line
	else
		zle kill-whole-line && _zsh-instant-repl_set-buffer
	fi
}
zle -N repl-kill-whole-line _zsh-instant-repl_kill-whole-line

function _zsh-instant-repl_backward-kill-line() {
	if [ "$LBUFFER" = "$INSTANT_REPL_PREFIX" ] \
		|| ([ -z "$LBUFFER" ] && [ -z "$INSTANT_REPL_TOGGLE_KILL_LINE" ]); then
		zle backward-kill-line
	else
		zle backward-kill-line && _zsh-instant-repl_set-buffer
	fi
}
zle -N repl-backward-kill-line _zsh-instant-repl_backward-kill-line
