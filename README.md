# vim popup-menu

Neovim native plugin library, that tries to mimic the behavior of the autocomplete popup menu.

## Usage

First parameter must be the list of selectable options
The second parameter must be a callback, that expects one parameter which will be the text of the selected line.

```vim
call popup_menu#open(['first', 'second', 'third'], { selected -> nvim_err_writeln(selected) } )
```

## Installation

Install using your favorite package manager, or use Vim's built-in package support:

```sh
mkdir -p ~/.vim/pack/library/start
cd ~/.vim/pack/library/start
git clone https://github.com/Ajnasz/vim-popup-menu.git
```
