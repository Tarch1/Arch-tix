sudo pacman -S ttf-roboto rofi sxiv feh python-pywal lxappearance imagemagick pacman-contrib slock dunst tcl tk --noconfirm
mkdir ~/{.wallpapers,.config/{kitty,polybar,rofi,dunst}}
#sudo mkdir -p /usr/share/slim/themes/minimal/

sudo ntpd -qg
echo "Time set"

###################-COPYING-###################

cp -r /media/internal_hdd/OS/Wallpapers/* ~/.wallpapers
cp ~/Arch-tix/Conf_files/picom.conf ~/.config/picom.conf

cp ~/Arch-tix/Conf_files/Dunst/dunstrc ~/.config/dunst/dunstrc
cp ~/Arch-tix/Conf_files/Script/Dunst/dunst-color.sh ~/.config/dunst/dunst-color.sh 

cp ~/Arch-tix/Conf_files/Script/toggle-touchpad.sh ~/.config/toggle-touchpad.sh
cp ~/Arch-tix/Conf_files/Script/low-battery.sh ~/.config/low-battery.sh

cp ~/Arch-tix/Conf_files/config.rasi ~/.config/rofi/config.rasi

cp ~/Arch-tix/Conf_files/kitty.conf ~/.config/kitty/kitty.conf
cp ~/Arch-tix/Conf_files/Script/pfetch ~/.pfetch
cp ~/Arch-tix/Conf_files/nanorc ~/.nanorc

cp /etc/X11/xinit/xinitrc ~/.xinitrc
echo 'Xft.dpi: 90' > ~/.Xdefaults
sudo echo "light -S 30" >> ~/.xprofile

sudo cp ~/Arch-tix/Conf_files/40-libinput.conf /usr/share/X11/xorg.conf.d/40-libinput.conf
sudo ln -s /usr/share/X11/xorg.conf.d/40-libinput.conf /etc/X11/xorg.conf.d/40-libinput.conf

sudo cp ~/Arch-tix/Conf_files/90-backlight.rules /usr/lib/udev/rules.d/90-backlight.rules


#sudo sed -i '/current_theme/ s/default/minimal/' /etc/slim.conf 
#sudo cp ~/Arch-tix/Conf_files/Slim-DM/slim.theme /usr/share/slim/themes/minimal/
#sudo cp ~/Arch-tix/Conf_files/Slim-DM/panel.png /usr/share/slim/themes/minimal/

###################-PERMISSIONS-###################

chmod +x ~/.xinitrc
chmod +x ~/.config/toggle-touchpad.sh
chmod +x ~/.config/dunst/dunst-color.sh
chmod +x ~/.config/low-battery.sh
chmod +x ~/.pfetch


###################-EXECUTION-###################

sudo sed -i '/ntfs/ s/ro/rw/' /etc/fstab
sudo ntfsfix /dev/sda1

#wpg-install.sh -b -g -i
