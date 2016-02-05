#! /bin/bash
#If you're using fish as main shell execute only with bash:
# fish > bash Binjitsu_installer.sh
#Avoid to install each one manually.
#feedback: hfjimenez@utp.edu.co, c1b3rh4ck@gmail.com
#Pereira Security Team.

#Colors
   r='\e[0;31m'       #Red, Blue, Yello, Cyan.
   r2='\e[1;31m'      #Warning
   b='\e[0;34m'
   b2='\e[1;34m'
   y='\e[0;36m'       #Installing
   y2='\e[1;33m'
   c='\e[0;36m'       #Success.
   fin='\e[0m'        #EOF

userhome=`pwd`

echo -e "${y}
  ____  _           _ _ _   ____
 | __ )(_)_ __     | (_) |_/ ___| _   _
 |  _ \| | '_ \ _  | | | __\___ \| | | |
 | |_) | | | | | |_| | | |_ ___) | |_| |
 |____/|_|_| |_|\___/|_|\__|____/ \__,_|
 Quick Installer of RE and Cracking Tools
      ${r}PereiraSecTeam${fin}"
echo
date;

echo -e "${y}Verifying Git installation${fin}\n"
if [ -x '/usr/bin/git' ]; then
    echo -e "\n${c}[*]Git Ok${fin}"
    echo -e "\n${y}[!]${fin}Installing Git"
    echo -e "\n${y}Updating your packages"
    sudo apt-get update>/dev/null && sudo apt-get dist-upgrade -y >/dev/null #This make apt-get to be more quiet.
    sudo apt-get install -y git >/dev/null
    echo -e "${c}[*]Done${fin}\n"
fi

sudo apt-get install -y python3-pip >/dev/null
sudo apt-get install -y gdb gdb-multiarch >/dev/null
# QEMU with MIPS/ARM -
#http://reverseengineering.stackexchange.com/questions/8829/cross-debugging-for-mips-elf-with-qemu-toolchain
echo -e "\n${y}[!]Installing Cross-Debugging for mips,elf with qemu toolchain${fin}"
sudo apt-get install -y qemu qemu-user qemu-user-static>/dev/null
sudo apt-get install -y 'binfmt*'>/dev/null
sudo apt-get install -y libc6-armhf-armel-cross debian-keyring>/dev/null
sudo apt-get install -y debian-archive-keyring>/dev/null
sudo apt-get install -y emdebian-archive-keyring>/dev/null
echo -e "\n${y}[!]Adding new Package repositories${fin}"
tee /etc/apt/sources.list.d/emdebian.list << EOF
deb http://mirrors.mit.edu/debian squeeze main
deb http://www.emdebian.org/debian squeeze main
EOF
sudo apt-get install -y libc6-mipsel-cross>/dev/null #This packages are only iin mit and emdebian repository.
sudo apt-get install -y libc6-arm-cross>/dev/null
echo -e "\n${y}[!]Setting Up qemu-binfmt${fin}"
mkdir /etc/qemu-binfmt
ln -s /usr/mipsel-linux-gnu /etc/qemu-binfmt/mipsel
ln -s /usr/arm-linux-gnueabihf /etc/qemu-binfmt/arm
rm /etc/apt/sources.list.d/emdebian.list
echo -e "${c}[*]Done${fin}\n"

# Binjitsu
echo -e "\n${y}[!]Installing Python 2.7 Version and Python Dev${fin}"
sudo apt-get install -y python2.7 python-pip python-dev>/dev/null
echo -e "${y}[!]Upgrading Binjitsu${fin}"
sudo pip install --upgrade git+https://github.com/binjitsu/binjitsu.git
echo -e "${c}[*]Done${fin}\n"
echo -e "\n${y}All you Reverse Engineering tools in /tools${fin}"
cd /home/${userhome}
mkdir tools
cd tools
# pwndbg
echo -e "\n${y}[!]Cloning and installing Pwndbg${fin}"
git clone https://github.com/zachriggle/pwndbg
echo source `pwd`/pwndbg/gdbinit.py >> ~/.gdbinit
echo -e "\n${y}[!]Installing Capstone for Pwndbg${fin}"
git clone https://github.com/aquynh/capstone
cd capstone
git checkout -t origin/next
sudo ./make.sh install>/dev/null
cd bindings/python
sudo python3 setup.py install # Ubuntu 14.04+, GDB uses Python3
echo -e "${c}[*]Done${fin}\n"
# pycparser for pwndbg
echo -e "\n${y}[!]Installing Pycparser for Pwndbg${fin}"
sudo pip3 install pycparser   # Use pip3 for Python3
echo -e "${c}[*]Done${fin}\n"

# Install radare2
echo -e "\n${y}[!]Installing Radare :) ${fin}"
git clone https://github.com/radare/radare2
cd radare2
./sys/install.sh>/dev/null
echo -e "${c}[*]Done${fin}\n"

# Install binwalk
echo -e "\n${y}[!]Installing Binwalk  ${fin}"
cd
git clone https://github.com/devttys0/binwalk
cd binwalk
sudo python setup.py install
echo -e "${c}[*]Done${fin}\n"

echo -e "\n${y}[!]Installing Firmware-Mod-Kit ${fin}"
sudo apt-get -y install git build-essential zlib1g-dev liblzma-dev python-magic>/dev/null
cd ~/tools
wget https://firmware-mod-kit.googlecode.com/files/fmk_099.tar.gz
tar xvf fmk_099.tar.gz>/dev/null
rm fmk_099.tar.gz
cd fmk_099/src
./configure>/dev/null						#In one step by step just if the ./configure break out the installation.
make>/dev/null
echo -e "${c}[*]Done${fin}\n"

echo -e "\n${y}[!]Updating Capstone ${fin}"
# Uninstall capstone
sudo pip2 uninstall capstone -y

# Install correct capstone
cd ~/tools/capstone/bindings/python
sudo python setup.py install
echo -e "${c}[*]Done${fin}\n"

# Personal config
echo -e "\n${y}[!]Installing The BarberShopper DotFiles ${fin}"
sudo sudo apt-get -y install stow
cd /home/${user}
echo -e "\n${y}[¡]Backing Up your dot files${fin}"
mkdir backupdot
mv  .bashrc backupdot
mv  .gitconfig backupdot

if [ -f .tmux.conf ];
then
    mv .tmux.conf backupdot
fi
mv .vimrc vim/ backupdot
echo -e "${c}[*]Done${fin}\n"
echo -e "\n${y}[!]Installing Alternative Dotfiles Configuration ${fin}"
git clone https://github.com/thebarbershopper/dotfiles
cd dotfiles
./install.sh
cd
echo -e "\n${c}[*]DONE, try gdb binaryfile it should say pwngdb ${fin}"
