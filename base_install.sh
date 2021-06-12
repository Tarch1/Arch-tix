#!/bin/bash

function main(){
	
	###### Localization-Settings #####
	
	distro="Artix"				#Arch or Artix
	hostn="tarch1"
	user="tarch1"
	localization="en_GB.UTF-8"
	language="en_US.UTF-8"			#"it_IT.UTF-8"
	timezone="Europe/Rome"
	
	###### Disk-Settings #####

	label="LABEL"				#LABEL UUID PARTUUID
	bootlabel="BOOT"
	rootlabel="ROOT"
	mounting="btrfsmount"			#ext4mount or btrfsmount
	bootloader="refind"			#grub refind efistub
	filesystem="btrfs -f"			#ext4 -F or btrfs -f
	
	###### Package #####
	
	microcode="intel-ucode"
	linux="base base-devel linux linux-firmware"
	init=""
	dev="wget git ntp linux-headers"
	baseutils="man bash-completion kitty vim nano"
	fs="efibootmgr os-prober mtools parted dosfstools sbsigntools ntfs-3g gvfs-mtp"
	net="networkmanager network-manager-applet"
	audio="pipewire pipewire-pulse pipewire-alsa pipewire-jack"  #pulseaudio pulseaudio-bluetooth pavucontrol ##pulseaudio-alsa alsa-utils , for wine use (lib32-libpulse lib32-alsa-plugins)
        android="android-tools android-udev"
	bluetooth="bluez bluez-utils bluez-plugins"
 	print="cups cups-pdf avahi"
	##xorg="xorg-server xorg-xinit xorg-xinit light numlockx libinput xorg-xinput xss-lock" 
	apps="telegram-desktop firefox feh calc fd bpytop" #for netwotk bmon
	graphics="mesa nvidia-prime nvidia nvidia-utils lib32-nvidia-utils nvidia-settings"
	hardwareacceleration="libva-mesa-driver mesa-vdpau intel-media-driver"
	vulkan="vulkan-icd-loader lib32-vulkan-icd-loader lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-mesa-layers"
	#filemanager="xed vifm pcmanfm tumbler raw-thumbnailer"
	archive="file-roller atool bzip2 cpio gzip lha xz lzop p7zip tar unrar zip unzip"
	#media="celluloid mate-utils pantheon-screenshot simplescreenrecorder"
	elogind=""
	rc="ntp-openrc avahi-openrc cups-openrc bluez-openrc networkmanager-openrc"
	stage=0    
	
	(
	set -e
	if [[ -z "$@" ]]
	then
		install || echo !!!!!!!!!!!!!!!!!!!! ERROR AFTER $stage !!!!!!!!!!!!!!!!!!!!
	fi
	)
}

function install(){
	$distro && stage=distro;
	diskpart && stage=diskpart;
	diskformat && stage=diskformat;
	$mounting && stage=$mounting;
	externaldrive && stage=externaldrive;
	baseinstall && stage=baseinstall;
	synctime && stage=synctime;
	localgen && stage=localgen;
	sethosts && stage=sethosts;
	systempkg && stage=systempkg;
	$services && stage=$services;
	audio && stage=audio;
	usersetup && stage=usersetup;
	$bootloader && stage=$bootloader						
}

function Arch() {
	keylayout="KEYMAP=it"			
	keypath="etc/vconsole.conf"		
	pkgstrap="pacstrap"			
	fstab="genfstab"			
	chroot="arch-chroot" 		
	services="archservices"	
	sed -i 's/lightdm-openrc//' ../Arch-tix/Setup-script/dm-setup.sh
	sed -i 's/openrc//' ../Arch-tix/Conf_files/Gnome/gnome-setup.sh 
}

function Artix() {
	keylayout="keymap="it""			
	keypath="etc/conf.d/keymaps"		
	pkgstrap="basestrap"			
	fstab="fstabgen"			
	chroot="artix-chroot" 		
	services="artservices"	
	init="openrc"
	rcpacks=$rc
        elogind="elogind elogind-openrc"
	pacman-key --init
        pacman-key --populate artix
	pacman -Sy --noconfirm artix-archlinux-support
}

function diskpart(){
 	pacman -Sy --noconfirm parted gptfdisk mtools ntfs-3g dialog
	devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
	DRIVE=$(dialog --stdout --menu "Select installation disk" 0 0 0 ${devicelist}) || exit 1
	#sgdisk --zap-all $DRIVE
	#sgdisk --clear \
        # --new=1:0:+550MiB --typecode=1:ef00 \
        # --new=2:0:0       --typecode=2:8300 \
        #   $DRIVE
	#sgdisk --verify $DRIVE
	parted --script $DRIVE mklabel gpt \
  	mkpart ESP fat32 0% 513MiB \
  	set 1 boot on \
  	mkpart primary btrfs 513MiB 100%
	BOOT_PART="$(ls ${DRIVE}* | grep -E "^${DRIVE}p?1$")"
	ROOT_PART="$(ls ${DRIVE}* | grep -E "^${DRIVE}p?2$")"
}

function diskformat(){
	mkfs.fat -F32 -n EFI $BOOT_PART
	mkfs.$filesystem $ROOT_PART
	mlabel -i $BOOT_PART ::"$bootlabel"
}

function btrfsmount(){
	btrfsdep="snapper btrfs-progs"
	btrfs filesystem label $ROOT_PART "$rootlabel"
	mount $ROOT_PART /mnt
	btrfs su cr /mnt/@
	btrfs su cr /mnt/@home
	btrfs su cr /mnt/@snapshots
	umount /mnt
	mount -o noatime,compress=lzo,space_cache=v2,subvol=@ $ROOT_PART /mnt
	mkdir -p /mnt/{boot,home,.snapshots}
        mount -o noatime,compress=lzo,space_cache=v2,subvol=@home $ROOT_PART /mnt/home
	mount -o noatime,compress=lzo,space_cache=v2,discard=async,subvol=@snapshots $ROOT_PART /mnt/.snapshots
	mount $BOOT_PART /mnt/boot
	#
	sed -i "s/username/$user/g" ../Arch-tix/Setup-script/snapper.sh
	lsblk -f
	sed -i 's/MODULES=()/MODULES=(btrfs)/g' ../Arch-tix/Conf_files/mkinitcpio.conf
	sed -i '/snapper/ s/#//' ../Arch-tix/full-setup.sh 
}

function ext4mount(){
	e2label $ROOT_PART "$rootlabel"
	mount $ROOT_PART /mnt
	mkdir /mnt/boot
	mkdir /mnt/boot
	mount $BOOT_PART /mnt/boot
	lsblk -f
}

function externaldrive(){
	mkdir -p /mnt/media/{internal_hdd,USB}
	mount /dev/sda1 /mnt/media/internal_hdd
}

function baseinstall(){
	$pkgstrap /mnt $linux $microcode $init $btrfsdep $elogind
	$fstab -U /mnt >> /mnt/etc/fstab 
	cat /mnt/etc/fstab
}

function synctime(){
	$chroot /mnt ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
	#echo "TIMEZONE=$timezone" >> /mnt/etc/rc.conf
	#echo "HARDWARECLOCK=$HARDWARECLOCK" >> /mnt/etc/rc.conf
	#echo "KEYMAP=$KEYMAP" >> /mnt/etc/rc.conf
	#echo "FONT=$FONT" >> /mnt/etc/rc.conf
	#echo "TTYS=$TTYS" >> /mnt/etc/rc.conf
	$chroot /mnt hwclock --systohc --utc
}

function localgen(){
	sed -i "/$localization/s/^#//g" /mnt/etc/locale.gen
	$chroot /mnt locale-gen
	echo "LANG=$language" >> /mnt/etc/locale.conf
  	echo "$keylayout" >> /mnt/$keypath
}

function sethosts (){
	echo $hostn >> /mnt/etc/hostname
	echo 127.0.0.1  localhost >> /mnt/etc/hosts
	echo ::1  localhost >> /mnt/etc/hosts
	echo 127.0.1.1  $hostn.localdomain  $hostn >> /mnt/etc/hosts
}

function systempkg(){
	$chroot /mnt pacman -Syu --noconfirm artix-archlinux-support
	$chroot /mnt pacman-key --populate archlinux
  	echo "[extra]" >> /mnt/etc/pacman.conf 
  	echo "Include = /etc/pacman.d/mirrorlist-arch" >> /mnt/etc/pacman.conf 
  	echo "[community]" >> /mnt/etc/pacman.conf 
  	echo "Include = /etc/pacman.d/mirrorlist-arch" >> /mnt/etc/pacman.conf 
  	echo "[multilib]" >> /mnt/etc/pacman.conf 
  	echo "Include = /etc/pacman.d/mirrorlist-arch" >> /mnt/etc/pacman.conf
	sed -i '/\[lib32\]/,/mirrorlist/ s/#//' /mnt/etc/pacman.conf
	$chroot /mnt pacman -Syy $dev $fs $net $bluetooth $audio $android $archive $filemanager $print $graphics $vulkan $hardwareacceleration $xorg $baseutils $apps $media $rcpacks --noconfirm
	cp ../Arch-tix/Conf_files/mkinitcpio.conf /mnt/etc/
	$chroot /mnt mkinitcpio -p linux
}

function systempkg1111111(){
  	#sed -i '/\[multilib\]/,/mirrorlist/ s/#//' /mnt/etc/pacman.conf 
	$chroot /mnt pacman -Syy $dev $fs $net $bluetooth $audio $android $archive $filemanager $print $graphics $vulkan $hardwareacceleration $xorg $baseutils $apps $media $rcpacks --noconfirm
	cp ../Arch-tix/Conf_files/mkinitcpio.conf /mnt/etc/
	$chroot /mnt mkinitcpio -p linux
}

function artservices(){
	$chroot /mnt rc-update add NetworkManager default
	#$chroot /mnt rc-update add keymaps boot
	$chroot /mnt rc-update add cupsd default
	$chroot /mnt rc-update add avahi-daemon default
	$chroot /mnt rc-update add bluetoothd default
	#$chroot /mnt tlp start || true
}

function archservices(){
	$chroot /mnt systemctl enable NetworkManager
	$chroot /mnt systemctl enable org.cups.cupsd.service
	$chroot /mnt systemctl enable avahi-daemon.service
	#$chroot /mnt tlp start || true
}

function audio(){
	##echo "options snd-hda-intel model=auto" | sudo tee -a /mnt/etc/modprobe.d/alsa-base.conf
	##echo "blacklist snd_soc_skl" | sudo tee -a /mnt/etc/modprobe.d/blacklist.conf
	#echo "options snd-hda-intel dmic_detect=0" | sudo tee -a /mnt/etc/modprobe.d/alsa-base.conf
	echo "options snd-intel-dspcfg dsp_driver=1" >> /mnt/etc/modprobe.d/dsp.conf
	echo "no audio setup"
}

function usersetup(){	
	$chroot /mnt useradd -mG wheel,video,storage,input $user
	sed -i '/%wheel ALL=(ALL) ALL/s/# //' /mnt/etc/sudoers
	sed -i 's/"us"/"it"/' /etc/conf.d/keymaps 
	$chroot /mnt echo $user
	$chroot /mnt passwd $user
	$chroot /mnt echo su
	$chroot /mnt passwd
	cp ../Arch-tix/Conf_files/bashrc /mnt/home/tarch1/.bashrc
	touch /mnt/etc/environment
	sed -i "$ a\Exec=env MOZ_ENABLE_WAYLAND=1 /usr/lib/firefox/firefox %u" /mnt/etc/environment
}

function grub(){
	$chroot /mnt pacman -Syy grub grub-btrfs --noconfirm
	$chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
	mkdir /mnt/boot/grub/themes
	sed -i '$ a\GRUB_THEME="/boot/grub/themes/Grub-Eiffel/theme.txt"' /mnt/etc/default/grub
 	$chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
	cp -r Bootloader/Grub-Eiffel /mnt/boot/grub/themes/
}

function refind(){
	$chroot /mnt pacman -Sy refind --noconfirm
	$chroot /mnt refind-install
	mkdir /mnt/boot/EFI/refind/themes
	mv /mnt/boot/EFI/refind/refind.conf /mnt/boot/EFI/refind/backup-refind.conf
	mv /mnt/boot/refind_linux.conf /mnt/boot/backup-refind_linux.conf
	cp Bootloader/Refind/refind.conf /mnt/boot/EFI/refind/refind.conf
	cp Bootloader/Refind/refind_linux.conf /mnt/boot/refind_linux.conf
	cp -r Bootloader/Refind/Refind-theme /mnt/boot/EFI/refind/themes/
}

function efistub(){
	uuid="$(blkid -s $label -o value $ROOT_PART)"
	$chroot /mnt efibootmgr -c -d /dev/nvme0n1 -p 1 -L "$distro" -l /vmlinuz-linux -u 'rw root=$label=$uuid rootflags=subvol=@ initrd=\intel-ucode.img initrd=\initramfs-linux.img' --verbose
	echo efibootmgr -b lastnumber -B  #delete previous boot entries
}

main "$@"

cp -r ../Arch-tix /mnt/home/$user/

#umount -R /mnt

