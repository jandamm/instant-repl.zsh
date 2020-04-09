zle-line-init() if [[ $CONTEXT = start ]] LBUFFER=$zle_prefix$LBUFFER
zle -N zle-line-init

prime-zle-prefix() zle_prefix=$LBUFFER
zle -N prime-zle-prefix
