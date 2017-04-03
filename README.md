git-switch
==========

Git command to make branch switching easier

## Installation

for zsh users:

```zsh
zplug "b4b4r07/git-switch", as:command, rename-to:git-switch
```

by hand:

```console
$ git clone https://github.com/b4b4r07/git-switch && cd git-switch
$ chmod 755 git-switch.sh
$ cp git-switch.sh {any PATH}/git-switch
```

## Usage

```console
$ git switch
>
add-vim-indicator
backup-db
selector-ui
remotes/origin/add-vim-indicator
remotes/origin/backup-db
remotes/origin/cols
remotes/origin/selector-ui
remotes/origin/show-columns
```

### alias

```
$ git config --global alias.sw switch
```

## License

MIT

## Author

b4b4r07
