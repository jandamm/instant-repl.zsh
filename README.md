# zsh-instant-repl
Activate a REPL for any command in your current zsh session.

## Motivation
I started using [gitsh](https://github.com/thoughtbot/gitsh) a while ago and really liked to quickly navigate git.
But the more I configured zsh the less fun it was to use `gitsh`.
It lacked some completions, the prompt is way less configurable and using [fzf-tab](https://github.com/Aloxaf/fzf-tab) also feels way better than completion of `readline`.

I jotted down what I'd need of zsh to be satisfied:
1. Interpret every command as a `git` command
2. Empty prompt is a default command (`git status`)
3. Prompt showing the current git status

The second and third point aren't a real problem.

For the first point I've written this plugin.

See my [dotfiles](https://github.com/jandamm/dotfiles/tree/master/zsh) for an implementation.

See **Hints** for a short description.

## Installation
See example below for more configuration

### [zinit](https://github.com/zdharma/zinit)
```zsh
zinit light jandamm/zsh-instant-repl

# This binds setting the REPL to Control-O
# You can use this plugin without keybindings if you prefer.
bindkey '^o' repl-set
```

### manual
- Clone and source `zsh-instant-repl.plugin.zsh`.
- Set a key binding for `repl-set`: `bindkey '^o' repl-set`

## Usage
You have two ways to use this:

### Keybinding

- Type a command. (e.g. `git `)
- Press the assigned keystroke. (e.g. `control-o`)
- Then your in the REPL mode.
- To exit the REPL clear the prompt and press the keystroke again.

### By script/command

Set the variable `INSTANT_REPL_PREFIX` to your REPL command. (e.g. `git `)

## Example

```zsh
zinit light jandamm/zsh-instant-repl

bindkey '^o' repl-set
# bindkey '^u' repl-backward-kill-line
bindkey '^u' repl-kill-whole-line # zsh default
```

## Configuration
Here is a list of all functions you can bind keys to and variables to change the plugins behavior.

### ZLE functions
You can use these functions with `bindkey [key] {function}`.
In scripts you can use them `zle {function}`

#### repl-set
Sets the current prompt content to use for REPL mode.

#### repl-clear
Clears the REPL mode for the next prompt.

#### repl-backward-kill-line
Changes backward-kill-line (bash `^u`) to kill the line except the REPL. If only the REPL exists it clears the line.
Configurable with `INSTANT_REPL_TOGGLE_KILL_LINE`.

#### repl-kill-whole-line
Changes kill-whole-line (bash `^u`) to kill the line except the REPL. If only the REPL exists it clears the line.
Configurable with `INSTANT_REPL_TOGGLE_KILL_LINE`.

### Variables
#### INSTANT_REPL_NO_AUTOFIX
By default there is exactly one space after the REPL when set via `repl-set`. If set, this behavior is disabled.

#### INSTANT_REPL_PREFIX
Represents the current REPL command.

#### INSTANT_REPL_TOGGLE_KILL_LINE
If set, `repl-backward-kill-line` and `repl-kill-whole-line` will restore the REPL if the prompt is empty.

## Hints
While it is nice to write some commands quicker, you can do more with it.

As stated in **Motivation** I wanted to replace `gitsh` with this plugin.

I call it `gsh` and for this I'm wrapping `repl-set` into another zle function:
```zsh
function repl-set-with-gsh() {
	# Check if I'm currently using git in INSTANT_REPL_PREFIX
	zle repl-set
	if [ using_git ] && [ ! was_using_git ]; then
		gsh_setup
	elif [ was_using_git ]; then
		gsh_unset
	fi
}
```

I also use a script to *start* gsh:
```zsh
INSTANT_REPL_PREFIX='git '
gsh_setup
```

## Credits
This code derives from work of [Stéphane Chazelas](https://unix.stackexchange.com/users/22565/st%C3%A9phane-chazelas) posted [here](https://unix.stackexchange.com/a/555734/405149).
