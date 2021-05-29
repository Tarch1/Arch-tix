sudo pacman -Syu gnome-shell chrome-gnome-shell gnome-control-center gdm gdm-openrc xdg-desktop-portal-gtk gnome-weather gnuchess gnome-chess gnome-calculator gnome-keyring evince --noconfirm
mkdir -p /etc/xdg/autostart/
cp ~/Arch-tix/Conf_files/Gnome/pipewire.desktop /etc/xdg/autostart/
cp ~/Arch-tix/Conf_files/Gnome/pipewire.sh ~/.config/
chmod +x ~/.config/pipewire.sh
