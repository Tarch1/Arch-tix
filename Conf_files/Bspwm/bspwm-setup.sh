sudo pacman -S bspwm sxhkd --noconfirm
mkdir ~/.config/{bspwm,sxhkd}
cp ~/Arch-tix/Conf_files/Bspwm/sxhkdrc ~/.config/sxhkd/sxhkdrc
cp ~/Arch-tix/Conf_files/Bspwm/bspwmrc ~/.config/bspwm/bspwmrc
chmod +x ~/.config/sxhkd/sxhkdrc
chmod +x ~/.config/bspwm/bspwmrc
