# instant-repl.zsh
Activate a REPL for any command in your current zsh session.

This plugin is very lightweight. It's source code is shorter than this readme :)
It does not add any keybindings. It's up to you to choose the bindings. If you don't have any preferences or feel overwhelmed by this customization options, just stick to the [Example](#example).

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

See [Hints](#hints) for a short description.

## Content

- [Description](#instant-replzsh)
- [Motivation](#Motivation)
- [Installation](#Installation)
- [Usage](#Usage)
- [Example](#Example)
- [Configuration](#Configuration)
  - [ZLE functions](#ZLE-functions)
  - [Hook](#Hook)
  - [Variables](#Variables)
- [Hints](#Hints)
- [Credits](#Credits)

## Installation
See example below for more configuration

### [zinit](https://github.com/zdharma/zinit)
```zsh
zinit light jandamm/instant-repl.zsh

# This binds setting the REPL to Control-O
# You can use this plugin without keybindings if you prefer.
bindkey '^o' repl-set
```

### manual
- Clone and source `instant-repl.zsh`.
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
zinit light jandamm/instant-repl.zsh

bindkey '^o' repl-set
# bindkey '^u' repl-backward-kill-line
bindkey '^u' repl-kill-whole-line # zsh default
# bindkey '^u' repl-kill-whole-line-toggle # zsh default, restores prefix when pressing with empty prompt.
```

## Configuration
Here is a list of all functions you can bind keys to and variables to change the plugins behavior.

Everything that is not listed here is considered implementation detail and should be treated as such.

### ZLE functions
You can use these functions with `bindkey [key] {function}`.
In functions you call from your own key binding functions you can use them like this: `zle {function}`.

Every ZLE function is also provided as function with the prefix `_instant_repl::`.
So calling `repl-set` from a script is possible via `_instant_repl::repl-set`.
Calling ZLE functions wrapping other zle functions is not supported (e.g. repl-kill-whole-line), as they are calling zle widgets themselves.

#### repl-set
Sets the current prompt content to use for REPL mode.

#### repl-clear
Clears the REPL mode for the next prompt.

#### repl-backward-kill-line
Changes backward-kill-line (bash `^u`) to kill the line except the REPL. If only the REPL exists it clears the line.

This can be used as a drop in replacement for backward-kill-line.

#### repl-backward-kill-line-toggle
See `repl-backward-kill-line`. When the prompt is empty this function will set the prompt to the prefix.

#### repl-kill-whole-line
Changes kill-whole-line (bash `^u`) to kill the line except the REPL. If only the REPL exists it clears the line.

This can be used as a drop in replacement for kill-whole-line.

#### repl-kill-whole-line-toggle
See `repl-kill-whole-line`. When the prompt is empty this function will set the prompt to the prefix.

#### repl-redraw-prompt
This zle function calls every precmd and then resets the prompt.
Use this if you want to update the prompt for certain prefixes.

### Hook
There is a hook which is called every time after the prefix has changed. **Be aware that this is not true if you set the prefix by assigning the [variable](#INSTANT_REPL_PREFIX).**

To use this hook define the function `instant_repl_prefix_hook`. You will get two parameters: The old prefix `$1` and the new prefix `$2`.

By default the hook is **not** called if the prefix does not change.

You can customize this hooks filter by changing `INSTANT_REPL_HOOK_FILTER`. The current filter is evaluated every time, so you can change it every time.

| Value | Behaviour |
| --- | --- |
| `equal` | Filter if the prefix hasn't changed (**default**) |
| `always` | Do not filter at all (use your own filter) |
| `never` | Turn hook off |
| `equal_command` | Filter if the prefix up until the first space is equal |
| `matching_old` | Filter if the new prefix begins with the old prefix |
| `matching_new` | Filter if the old prefix begins with the new prefix |
| `matching` | Filter if `matching_old` OR `matching_new` |

See [hints](#hints) for usage tips.

### Variables
### INSTANT_REPL_HOOK_FILTER
Defines when the hook should not be called. See [hook](#hook).

#### INSTANT_REPL_NO_AUTOFIX
By default there is exactly one space after the REPL when set via `repl-set`. If set, this behavior is disabled.

#### INSTANT_REPL_PREFIX
Represents the current REPL command.

## Hints
While it is nice to write some commands quicker, you can do more with it.

As stated in [Motivation](#motivation) I wanted to replace `gitsh` with this plugin.

I call it `gsh` and for this I'm using the [hook](#hook).
```zsh
function instant_repl_prefix_hook() {
	case $1 in
		git*)
			gsh_unset
			zle repl-redraw-prompt
		;;
	esac
	case $2 in
		git*)
			gsh_setup
			zle repl-redraw-prompt
		;;
	esac
}
```
I filter this hook using `equal_command`. This is working nicely with git, as the command won't change while using gsh.

If you're using instant-repl with docker you'll often have `sudo docker` as prefix.
You could start with `equal` and switch to `matching` when the prefix changes to `sudo docker` and to `equal_command` when the prefix is `git`:

```zsh
function instant_repl_prefix_hook() {
	# Change your shell
	case $2 in
	sudo docker*) INSTANT_REPL_HOOK_FILTER=matching ;;
	git*) INSTANT_REPL_HOOK_FILTER=equal_command ;;
	*) INSTANT_REPL_HOOK_FILTER=equal ;;
	esac
}
```

I also use a script to *start* gsh:
```zsh
INSTANT_REPL_PREFIX='git '
gsh_setup
```

## Credits
This code derives from work of [Stéphane Chazelas](https://unix.stackexchange.com/users/22565/st%C3%A9phane-chazelas) posted [here](https://unix.stackexchange.com/a/555734/405149).
