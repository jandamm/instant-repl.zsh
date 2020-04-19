function _instant_repl::zle-line-init() {
	local ret
	# call wrapped zle-line-init if it exists
	(( ! ${+widgets[._instant_repl::orig-zle-line-init]} )) || zle ._instant_repl::orig-zle-line-init $@
	ret=$?
	if [[ $CONTEXT = start ]]; then
		LBUFFER=$INSTANT_REPL_PREFIX$LBUFFER
	fi
	return $ret
}
# wrap previous zle-line-init if it exists
zle -A zle-line-init ._instant_repl::orig-zle-line-init 2>/dev/null
zle -N zle-line-init _instant_repl::zle-line-init

function _instant_repl::prefix() {
	local old_prefix
	old_prefix="$INSTANT_REPL_PREFIX"

	case $1 in
		set)
			if [ -z "$LBUFFER" ]; then
				unset INSTANT_REPL_PREFIX
			elif [ -n "$INSTANT_REPL_NO_AUTOFIX" ]; then
				INSTANT_REPL_PREFIX=$LBUFFER
			else
				INSTANT_REPL_PREFIX="$(echo $LBUFFER | sed 's/ *$//') "
			fi
			;;
		clear) unset INSTANT_REPL_PREFIX ;;
	esac

	case "$INSTANT_REPL_HOOK_FILTER" in
		always) ;;
		never) return ;;
		equal_command) [ ! "${old_prefix%% *}" = "${INSTANT_REPL_PREFIX%% *}" ] || return ;;
		*) [ ! "$old_prefix" = "$INSTANT_REPL_PREFIX" ] || return ;;
	esac

	(( ${+functions[instant_repl_prefix_hook]} )) && instant_repl_prefix_hook "$old_prefix" "$INSTANT_REPL_PREFIX"
}

function _instant_repl::repl-set() {
	_instant_repl::prefix set
}
zle -N repl-set _instant_repl::repl-set

function _instant_repl::repl-clear() {
	_instant_repl::prefix clear
}
zle -N repl-clear _instant_repl::repl-clear

function _instant_repl::repl-kill-whole-line() {
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
zle -N repl-kill-whole-line _instant_repl::repl-kill-whole-line

function _instant_repl::repl-backward-kill-line() {
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
zle -N repl-backward-kill-line _instant_repl::repl-backward-kill-line

function _instant_repl::repl-redraw-prompt() {
	local precmd
	for precmd in $precmd_functions; do
		$precmd
	done
	zle reset-prompt
}
zle -N repl-redraw-prompt _instant_repl::repl-redraw-prompt
