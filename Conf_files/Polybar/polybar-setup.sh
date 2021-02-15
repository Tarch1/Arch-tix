sudo pacman -S xdotool xorg-xwininfo xorg-xev
trizen -S polybar
mkdir ~/.config/polybar
cp ~/Arch-tix/Conf_files/Script/Polybar/hide ~/.config/polybar/hide
cp ~/Arch-tix/Conf_files/Script/Polybar/launch.sh ~/.config/polybar/launch.sh
cp ~/Arch-tix/Conf_files/Script/Polybar/config ~/.config/polybar/config
chmod +x ~/.config/polybar/launch.sh
chmod +x ~/.config/polybar/hide
