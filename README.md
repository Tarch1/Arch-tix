# Ar{ch-tix}
Universal installation script

STEP:

For wired connection use connman:

- Found the interface
- rfkill unblock all
- ip link interface up
- connmanctl :

     - scan wifi
     - services
     - agent on
     - connect wifi_***_psk
     - quit

git clone https://github.com/Tarch1/Arch-tix
cd Arch-tix/
adjust base_install.sh :

     - Localization-Settings
     - Filesystem-Settings
     - Package 

chmod +x set-permission.sh and run it (./*.sh)
run base_install.sh
reboot

nmtui to connect on your network 
run full-setup.sh

OPTIONAL: run the single command inside Setup-script instead of full-setup-sh :

     - run dm-setup.sh
     - run env-setup.sh
     - run snapper.sh
     - run trizen.sh
     - run wm-setup.sh
  
Reboot and Enjoy!
