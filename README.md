# zsh-instant-repl
Activate a REPL for any command in your current zsh session.

## Installation
See example below for more configuration

### [zinit](https://github.com/zdharma/zinit)
```zsh
zinit light jandamm/zsh-instant-repl

# This binds setting the REPL to Control-O
# You can use this plugin without keybindings if you prefer.
bindkey '^o' set-zle-repl
```

### manual
- Clone and source `zsh-instant-repl.plugin.zsh`.
- Set a key binding for `set-zle-repl`: `bindkey '^o' set-zle-repl`

## Usage
You have two ways to use this:

### Keybinding

- Type a command. (e.g. `git `)
- Press the assigned keystroke. (e.g. `control-o`)
- Then your in the REPL mode.
- To exit the REPL clear the prompt and press the keystroke again.

### By script/command

Set the variable `ZSH_INSTANT_REPL_PREFIX` to your REPL command. (e.g. `git `)

## Example

```zsh
zinit light jandamm/zsh-instant-repl

bindkey '^o' set-zle-repl
```

## Configuration
Here is a list of all functions you can bind keys to and variables to change the plugins behaviour.

### ZLE functions (usable for bindkey)
#### set-zle-repl
Sets the current prompt content to use for REPL mode.

### Variables
#### ZSH_INSTANT_REPL_PREFIX
Represents the current REPL command.

## Credits
This code derives from work of [Stéphane Chazelas](https://unix.stackexchange.com/users/22565/st%C3%A9phane-chazelas) posted [here](https://unix.stackexchange.com/a/555734/405149).
