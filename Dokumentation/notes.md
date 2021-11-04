# Linux 

<!-- TOC -->
- [git](#git)
- [stow](#stow)
- [apt-get](#apt-get)
- [tmux](#tmux)
    - [Tmux Themepack](#tmux-themepack)
    - [Key-Bindings zuruecksetzen ⌨️](#key-bindings-zuruecksetzen-️)
    - [set the status line's colors](#set-the-status-lines-colors)
- [wget (download files from commandline)](#wget-download-files-from-commandline)
- [DEB-Paket installieren](#deb-paket-installieren)
- [Programme](#programme)
- [Aliases (oh-my-zsh)](#aliases-oh-my-zsh)
- [Autosuggestions in Oh My Zsh](#autosuggestions-in-oh-my-zsh)
- [nnn (file manager)](#nnn-file-manager)
- [unsorted](#unsorted)
<!-- /TOC -->


## git

Git Repo klonen `git clone git@github.com:WickedLink/konfiguration.git`

Alle Dateien aus dem aktuellen Verzeichnis hinzufuegen `git add .`

Beschreiben? `git commit -am "note"` :confused:

Dateien hochladen `git push`

Dateien herunterladen `git pull`

SSH-Key generieren `ssh-keygen -o` (wobei ich die Option -o nicht dokumentiert finde)

## stow

Jedes angelegte Verzeichnis wie tmux, vim wird als Homeverzeichnis angesehen.

Jede Aktion vorher mit dem Schalter `-n` testen!

`stow -nvt ~ htop`
- n - no (nur simulieren)
- v - verbose
- t - targetdir
- Mit `htop` wurde angegeben, dass nur htop verlinkt wird. Es koennen auch mehrere hintereinander angegeben werden. Soll alles verlinkt werden `stow -nvt ~ *` genauso `stow -nvSt ~ *` (S fuer stow)
- `stow -nvDt ~ *` delinkt Alles (hier nur simuliert)
- `stow -vDt ~ vim` delinkt nur vim
- `stow --adopt -nvt ~ *` alle Dateien in das Git-Verzeichnis uebertragen

## apt-get

`apt-get moo moo moo` nettes Easteregg 😜 :stuck_out_tongue_winking_eye:

## tmux

### Tmux Themepack

manuelle Installation

1. git-repo klonen `git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack`
2. entsprechendes Theme in der `~/.tmux.conf` sourcen: (haeh?) :confused:

    `source-file "${HOME}/.tmux-themepack/powerline/default/green.tmuxtheme"`

    In some linux distributions you might have to remove the quotation marks
    from the `source-file` command to avoid a `no such file or directory` error: `source-file ${HOME}/.tmux-themepack/powerline/default/green.tmuxtheme`

funzt: `tmux source-file "${HOME}/.tmux-themepack/powerline/default/green.tmuxtheme`

### Key-Bindings zuruecksetzen ⌨️

`unbind-key -a` alle key-bindings loesen

`source-file ~/.tmux.reset.conf` in Github abgelegt

### set the status line's colors
`set -g status-style fg=white,bg=blue`

aktuelle Einstellungen anzeigen `tmux show-options -g | grep status`

## wget (download files from commandline)

- download to current folder `wget http://example.com/file.tar`

Without supplying any extra parameters in the command, wget will save the downloaded file to whatever directory your terminal is currently set to. If you want to specify where the file should be saved, you can use the -O (output) option in the command. `wget http://example.com/file.tar -O /path/to/dir/file.tar`

## DEB-Paket installieren

`sudo dpkg -i lsd_0.20.1_amd64.deb`

## Programme

- zshell, oh-my-zshell
- tmux
- bashtop
- lsd (ls deluxe) `wget https://github.com/Peltoche/lsd/releases/download/0.20.1/lsd_0.20.1_amd64.deb`

## Aliases (oh-my-zsh)

Im Ordner `~/.oh-my-zsh/custom` eine beliebige `.zsh` Datei anlegen und dort die Aliases eintragen.

```sh
alias lda='lsd -al'  
alias ldas='lsd -al --total-size' 
alias la='lsd -al'
```

`la` ist schon vorher definiert, wird aber ueberschrieben.

Einstellungen danach noch sourcen. `source ~/.zshrc`

## Autosuggestions in Oh My Zsh

1. Clone this repository into `$ZSH_CUSTOM/plugins` (by default `~/.oh-my-zsh/custom/plugins`)

    ```sh
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    ```

2. Add the plugin to the list of plugins for Oh My Zsh to load (inside `~/.zshrc`):

    ```sh
    plugins=( 
        # other plugins...
        zsh-autosuggestions
    )
    ```

3. Start a new terminal session.

## nnn (file manager)

1. Repository klonen

    ```sh
    git clone https://github.com/jarun/nnn.git
    ```

2. Dependencies installieren.

    ```sh 
    sudo apt-get install pkg-config libncursesw5-dev libreadline-dev
    ``` 

3. Kompilieren fuer die Darstellung der Icons:

    ```sh
    sudo make O_NERD=1
    sudo make install
    ```
4. Im Plugin-Ordner die Plugins herunterladen:

    ```sh
    curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
    ```

5. Die `quitcd.bash_zsh` sourcen.

    In der `.zhrc` einfuegen:

    ```sh
    if [ -f /home/joshua/konfiguration/nnn/quitcd.bash_zsh ]; then
        source /home/joshua/konfiguration/nnn/quitcd.bash_zsh
    fi
    ```




---

## unsorted 

```sh
git config --global user.email "joshua.hawx@gmx.net"
git config --global user.name "wickedlink"
```

```sh
sudo make 0_NERD=1 strip install
cc  -std=c11 -Wall -Wextra -Wshadow -O3 -D_GNU_SOURCE -D_DEFAULT_SOURCE -I/usr/include/ncursesw  -o nnn  src/nnn.c -lreadline -lncursesw -ltinfo -lpthread
strip nnn
install -m 0755 -d /usr/local/bin
install -m 0755 nnn /usr/local/bin
install -m 0755 -d /usr/local/share/man/man1
install -m 0644 nnn.1 /usr/local/share/man/man1
```
