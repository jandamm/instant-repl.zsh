function _zsh-instant-repl::set-buffer() {
	LBUFFER=$INSTANT_REPL_PREFIX$LBUFFER
}

function _zsh-instant-repl::zle-line-init() {
	# call wrapped zle-line-init if it exists
	(( ! ${+widgets[._zsh-instant-repl::orig-zle-line-init]} )) || zle ._zsh-instant-repl::orig-zle-line-init $@
	local ret=$?
	if [[ $CONTEXT = start ]]; then
		_zsh-instant-repl::set-buffer
	fi
	return $ret
}
# wrap previous zle-line-init if it exists
(( ! ${+widgets[zle-line-init]} )) || zle -A zle-line-init ._zsh-instant-repl::orig-zle-line-init
zle -N zle-line-init _zsh-instant-repl::zle-line-init

function _zsh-instant-repl::repl-set() {
	if [ -n "$INSTANT_REPL_NO_AUTOFIX" ]; then
		INSTANT_REPL_PREFIX=$LBUFFER
	elif [ -z "$LBUFFER" ]; then
		unset INSTANT_REPL_PREFIX
	else
		INSTANT_REPL_PREFIX="$(echo $LBUFFER | sed 's/ *$//') "
	fi
}
zle -N repl-set _zsh-instant-repl::repl-set

function _zsh-instant-repl::repl-clear() {
	unset INSTANT_REPL_PREFIX
}
zle -N repl-clear _zsh-instant-repl::repl-clear

function _zsh-instant-repl::repl-kill-whole-line() {
	if [ -n "$INSTANT_REPL_PREFIX" ] \
		&& [[ "$LBUFFER" =~ $INSTANT_REPL_PREFIX* ]] \
		&& [ ! "$BUFFER" = "$INSTANT_REPL_PREFIX" ] \
		&& [ ! "$BUFFER " = "$INSTANT_REPL_PREFIX" ]; then
		BUFFER=$INSTANT_REPL_PREFIX
	elif [ -z "$BUFFER" ] && [ -n "$INSTANT_REPL_TOGGLE_KILL_LINE" ]; then
		LBUFFER=$INSTANT_REPL_PREFIX # Toggle if toggling is enabled
	else
		zle kill-whole-line
	fi
}
zle -N repl-kill-whole-line _zsh-instant-repl::repl-kill-whole-line

function _zsh-instant-repl::repl-backward-kill-line() {
	if [ -n "$INSTANT_REPL_PREFIX" ] \
		&& [[ "$LBUFFER" =~ $INSTANT_REPL_PREFIX* ]] \
		&& [ ! "$LBUFFER" = "$INSTANT_REPL_PREFIX" ] \
		&& [ ! "$LBUFFER " = "$INSTANT_REPL_PREFIX" ]; then
		LBUFFER=$INSTANT_REPL_PREFIX
	elif [ -z "$LBUFFER" ] && [ -n "$INSTANT_REPL_TOGGLE_KILL_LINE" ]; then
		LBUFFER=$INSTANT_REPL_PREFIX # Toggle if toggling is enabled
	else
		zle backward-kill-line
	fi
}
zle -N repl-backward-kill-line _zsh-instant-repl::repl-backward-kill-line

function _zsh-instant-repl::repl-redraw-prompt() {
	local precmd
	for precmd in $precmd_functions; do
		$precmd
	done
	zle reset-prompt
}
zle -N repl-redraw-prompt _zsh-instant-repl::repl-redraw-prompt
