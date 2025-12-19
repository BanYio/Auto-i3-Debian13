# Auto-i3-Debian13

Minimalist setup for **Debian13-GNOME**

## Instalation

After cloning the repo just run with sudo deploy-13-debian13.sh

```Shell
chmod +x deploy-13-debian13.sh
sudo ./deploy-13-debian13.sh
```

## Configuration
**Change i3-blocks and order for the header bar.**
go to:
````bash
cd .config/i3/  # file location
nano i3blocks.conf  # edit it with your preferred editor
````

**Change or add shortcuts**
````bash
cd .config/i3/ # file location
nano config  # edit it with your preferred editor
````

**Change wallpaper**
````bash
cd .config/i3/ # file location
nano config  # edit it with your preferred editor

# Change the line exec --no-startup-id sh -c 'sleep 1 && feh --no-fehbg --bg-fill /home/banyio/Pictures/porsche.jpg' put the path to your favorite wallpaper
````

## Shortcuts for window manager
| command | exec |
| :--- | :--- |
| Windows + Space | Program launcher |
| Windows + Enter | open kitty |
| Windows + Shift + Q | close focused window |
| Windows + Shift + R | Restar I3 manager |
| Windows + L | Lock session |


## Shortcuts for personal tools
| command | exec |
| :--- | :--- |
| Windows + O | Obsidian |
| Windows + Shift + S | Flameshot (screenshots) |
| Windows + P | ProtonVPN |
| Windows + G | Google-Chrome |
| Windows + Esc | Power Menu (Log-out, restart, power-off) |
| Windows + E | File Explorer (Nautilus) |


## Shortcuts for Kitty
| command | exec |
| :--- | :--- |
| Windows + Shift + T | New Tab |
| Ctrl + Shift + R | Split terminal right (vertical) |
| Ctrl + Shift + D | Split terminal down (horizontal) |
| Alt + arrows | Move to different terminal splits |
| Ctrl + Shift + arrows | Resize selected split |
| Ctrl + Tab | Move into tabs |


