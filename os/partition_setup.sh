# supports usb boot and usb root, so no problem!

printf "Windows 10 Raspberry Pi installer From NOOBS!"
install_zenity() {
wget https://raw.githubusercontent.com/JeromTWinL/windows-arm-noobs-installer/master/zenity.zip
wait
unzip zenity.zip -d /
wait
}

detect_disk() {
if echo "$part1" | grep /dev/mmcblk0; then
set disk=/dev/mmcblk0
elif echo "$part1" | grep /dev/sda; then
set disk=/dev/sda
elif echo "$part1" | grep /dev/sdb; then
set disk=/dev/sdb
elif echo "$part1" | grep /dev/sdc; then
set disk=/dev/sdc
elif echo "$part1" | grep /dev/sdd; then
set disk=/dev/sdd
else
printf "ERROR: couldn't detect disk!" 1>&2
exit 1
fi
}

download_wim() {

set FILEUUID="199P9lS3blZKUPAPgVtDlxPwBJOKdU1yg"
set FILENAME="/tmp/pe/sources/install.wim"
mkdir -p /tmp/pe/sources

wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id='"$FILEUUID" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$FILEUUID" -O "$FILENAME" 2>&1 | sed -u 's/^[a-zA-Z\-].*//; s/.* \{1,2\}\([0-9]\{1,3\}\)%.*/\1\n#Downloading... \1%/; s/^20[0-9][0-9].*/#Done./' | zenity --progress --percentage=0 --title=Download dialog --text='Starting... ' --auto-close --auto-kill
wait
rm -rf /tmp/cookies.txt
qait

}
download_installer() {
wget 
wait wget
unzip installer.zip -d /tmp/pe >/dev/null
wait unzip
}

format_partitions() {
mkfs.fat -n EFIESP "$part1"
wait mkfs.fat
mkfs.ntfs -L Windows "$part2" --fast
wait mkfs.ntfs
}

if [ -z "$part1" ] || [ -z "$part2" ]; then
printf "ERROR: there is no part1 and part2, try to reinstall!"
exit 1
fi

printf "ReFormatting partition..."
format_partitions
wait
install_zenity
wait

detect_disk
wait

echo 'a
2
w
' | fdisk "$disk" >/dev/null
wait

mkdir -p /tmp/pe
mount "$part1" /tmp/pe

printf "Downloading windows wim file, this takes some time according to your internet speed!"
download_wim
wait
printf "Downloaded windows wim!"

printf "Downloading installer!" 2>&1
download_installer
wait

zenity --info --width=520 --height=740 --text="You have installed windows 10 successfully \n, now follow the instructions to install windows 10 without any problems\n reboot system and install windows 10 using installer\n after that again boot installer and select language\n and you can see 'Repair your computer' (the computer not damaged ,just \n run one command or windows will enter a bsod)\n click Troubleshoot->Command Prompt ,at the \n command prompt ,run instdrvr and your system will reboot\n automatically, if u got a screen 'windows couldn't configure on this hardware' use Shift+F10 and when\n the command prompt open ,run fixthisscreen \n you'll get a prompt ,just press yes and ok, your system will reboot automatically ,and enjoy!!!!" --icon-name="/tmp/icon.png"
