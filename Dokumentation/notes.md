# Linux 
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
Tmux Themepack

Installation

manuelle Installation

1. git-repo klonen

       git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack

2. entsprechendes Theme in der `~/.tmux.conf` sourcen:

       source-file "${HOME}/.tmux-themepack/powerline/default/green.tmuxtheme"

    In some linux distributions you might have to remove the quotation marks
    from the `source-file` command to avoid a `no such file or directory` error:

       source-file ${HOME}/.tmux-themepack/powerline/default/green.tmuxtheme
