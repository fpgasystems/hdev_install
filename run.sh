#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#default constants
SGRT_INSTALL_PATH="/opt/sgrt"

MPICH_PATH="/opt/mpich"
MY_DRIVERS_PATH="/local/home"


SHARED_DRIVE_PATH="/home/$USER"
SGRT_PROJECTS_PATH="$SHARED_DRIVE_PATH/sgrt_projects" #MY_PROJECTS_PATH="/home/$USER/my_projects"
ROCM_PATH="/opt/rocm"
VIVADO_DEVICES_MAX="1"
XILINX_PLATFORMS_PATH="/opt/xilinx/platforms"
XILINX_TOOLS_PATH="/tools/Xilinx"
XRT_PATH="/opt/xilinx/xrt"

#check if the user has sudo capabilities
if ! sudo -n true 2>/dev/null; then
    echo ""
    echo "The installation process requires sudo capabilities."
    echo ""
    exit 1
fi

echo ""
echo "${bold}sgrt_install${normal}"

#get sgrt_install_path
echo ""
echo "${bold}Please, enter the installation path (default: $SGRT_INSTALL_PATH):${normal}"
while true; do
    read -p "" sgrt_install_path
    #assign to default if empty
    if [ -z "$sgrt_install_path" ]; then
        sgrt_install_path=$SGRT_INSTALL_PATH
    fi
    #the installation destination should not exist
    if ! [ -d "$sgrt_install_path" ]; then
        break
    fi
done

#get mpich_path
echo ""
#echo "${bold}Please, enter the value for MPICH_PATH (default: $MPICH_PATH):${normal}"
read -p "${bold}Please, enter the value for MPICH_PATH (default: $MPICH_PATH):${normal}" mpich_path
if [ -z "$mpich_path" ]; then
    mpich_path=$MPICH_PATH
    echo $mpich_path
fi

#get my_drivers_path
echo ""
echo "${bold}Please, enter the value for MY_DRIVERS_PATH (default: $MY_DRIVERS_PATH):${normal}"
read -p "" my_drivers_path
if [ -z "$my_drivers_path" ]; then
    my_drivers_path=$MY_DRIVERS_PATH
    echo $my_drivers_path
fi

#test
echo $sgrt_install_path
echo ""
echo $mpich_path
echo $my_drivers_path

#create files



#-----------------------------------------------------------------------------

exit


#authenticate as sudo and become root
sudo -s <<EOF

# Now you are running as root

# Change to the desired directory and create a folder
cd /local/home/root
mkdir -p prova
git clone https://github.com/fpgasystems/sgrt.git

# Exit from the root shell
exit

EOF

echo $SGRT_INSTALL_PATH
echo $sgrt_install_path
echo $local_path

exit

#hola desde 2023-5-1 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#operate as sudo
eval "sudo cd /local/home/root" 
eval "sudo git clone https://github.com/fpgasystems/sgrt.git"

echo $LOCAL_DRIVE_PATH

exit

#create the destination directory
sudo mkdir -p $sgrt_install_path

#checkout sgrt
cd $SHARED_DRIVE_PATH
git clone https://github.com/fpgasystems/sgrt.git

#cleanup sgrt

#move sgrt
#sudo mv $SHARED_DRIVE_PATH/sgrt/* $sgrt_install_path
#sudo rsync -av $SHARED_DRIVE_PATH/sgrt $sgrt_install_path
sudo sh -c "cd '$SHARED_DRIVE_PATH/sgrt' && rsync -av . '$sgrt_install_path/'"

#derive CLI path
CLI_PATH="$sgrt_install_path/cli"

#save constants
echo "$local_path" > "$CLI_PATH/constants/LOCAL_DRIVE_PATH"



