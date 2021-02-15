sudo umount /.snapshots/
sudo rm -rf /.snapshots
sudo snapper -c root create-config /
sudo btrfs su del /.snapshots
sudo mkdir /.snapshots
sudo chmod 750 /.snapshots

sudo sed -i 's/ALLOW_USERS=""/ALLOW_USERS="username"/g' /etc/snapper/configs/root
sudo sed -i 's/TIMELINE_LIMIT_HOURLY="10"/TIMELINE_LIMIT_HOURLY="3"/g' /etc/snapper/configs/root
sudo sed -i 's/TIMELINE_LIMIT_DAILY="10"/TIMELINE_LIMIT_DAILY="2"/g' /etc/snapper/configs/root
sudo sed -i 's/TIMELINE_LIMIT_WEEKLY="0"/TIMELINE_LIMIT_WEEKLY="1"/g' /etc/snapper/configs/root
sudo sed -i 's/TIMELINE_LIMIT_MONTHLY="10"/TIMELINE_LIMIT_MONTHLY="1"/g' /etc/snapper/configs/root
sudo sed -i 's/TIMELINE_LIMIT_YEARLY="10"/TIMELINE_LIMIT_YEARLY="1"/g' /etc/snapper/configs/root

sudo chmod a+rx /.snapshots
sudo chown :tarch1 /.snapshots

sudo mkdir /etc/pacman.d/hooks
sudo cp ~/Arch-tix/Conf_files/50-bootbackup.hook /etc/pacman.d/hooks/50-bootbackup.hook
sudo pacman -S rsync --noconfirm

#rc-update add snapper-timeline.timer default
#rc-update add snapper-timeline.timer default
#rc-update add snapper-cleanup.timer default
#rc-update add snapper-cleanup.timer default
#rc-update add grub-btrfs.path default
#rc-update add grub-btrfs.path default
