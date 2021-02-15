sudo pacman -Sy lightdm-webkit2-greeter lightdm-webkit-theme-litarvan lightdm-openrc --noconfirm
sudo sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-webkit2-greeter/' /etc/lightdm/lightdm.conf
sudo sed -i 's/antergos/litarvan/g' /etc/lightdm/lightdm-webkit2-greeter.conf
#sudo pacman -Sy slim
#sudo sed -i '$ a\default_user    tarch1' /etc/slim.conf
sudo rc-update add lightdm default
