# Ar{ch-tix}
Universal installation script

STEP:

Find your interface with: 

     - ip a
     - rfkill unblock all
     - ip link interface up

then use connmanctl:

     - scan wifi
     - services
     - agent on
     - connect wifi_***_psk
     - quit

git clone https://github.com/Tarch1/Arch-tix
cd Arch-tix/
adjust base_install.sh:

     - Localization-Settings
     - Filesystem-Settings
     - Package 

chmod +x set-permission.sh and run it (./*.sh)
run base_install.sh
reboot

nmtui to connect on your network 
run full-setup.sh

OPTIONAL: run the single command inside Setup-script instead of full-setup-sh:

     - run dm-setup.sh
     - run env-setup.sh
     - run snapper.sh
     - run trizen.sh
     - run wm-setup.sh
  
Reboot and Enjoy!

PS: if gnome on wayland not start's on machine's with hybrid gpu setup comment << DRIVER=="nvidia"......>> rule at /lib/udev/rules.d/61-gdm.rules
     addition for super+n navigation use:  for i in {1..9}; do gsettings set "org.gnome.shell.keybindings" "switch-to-application-$i" "[]"; done, checking that they are properly unset with gsettings list-recursively | grep switch-to-application | sort
