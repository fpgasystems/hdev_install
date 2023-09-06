#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#default constants
SGRT_INSTALL_PATH="/opt/sgrt"
LOCAL_DRIVE_PATH="/local/home/$USER" #LOCAL_PATH="/local/home/$USER"
MPICH_PATH="/opt/mpich"
SHARED_DRIVE_PATH="/home/$USER"
SGRT_PROJECTS_PATH="$SHARED_DRIVE_PATH/sgrt_projects" #MY_PROJECTS_PATH="/home/$USER/my_projects"
ROCM_PATH="/opt/rocm"
VIVADO_DEVICES_MAX="1"
XILINX_PLATFORMS_PATH="/opt/xilinx/platforms"
XILINX_TOOLS_PATH="/tools/Xilinx"
XRT_PATH="/opt/xilinx/xrt"

#get username
#username=$(getent passwd ${SUDO_UID})
#username=${username%%:*}

#echo $username

#- ACAP_SERVERS_LIST
#- CPU_SERVERS_LIST
#- FPGA_SERVERS_LIST
#- GPU_SERVERS_LIST
    #- LOCAL_PATH
    #- MPICH_PATH
    #- MY_PROJECTS_PATH
    #- ROCM_PATH  
#- VIRTUALIZED_SERVERS_LIST
    #- VIVADO_DEVICES_MAX
#- XILINX_PLATFORMS_PATH
#- XILINX_TOOLS_PATH
#- XRT_PATH

#check if the script is run with sudo
#if [ "$EUID" -ne 0 ]; then
#    echo ""
#    echo "This script must be run with sudo. Please use 'sudo $0' to execute it."
#    echo ""
#    exit 1
#fi

#check if the user has sudo capabilities
if ! sudo -n true 2>/dev/null; then
    echo ""
    echo "The installation process requires sudo capabilities."
    echo ""
    exit 1
#else
#    echo "User has sudo capabilities."
fi

echo ""
echo "${bold}sgrt_install${normal}"

#get sgrt_install_path
echo ""
read -p "${bold}Please, enter the installation path (default: $SGRT_INSTALL_PATH):${normal} " sgrt_install_path
if [ -z "$sgrt_install_path" ]; then
    sgrt_install_path=$SGRT_INSTALL_PATH
fi

#check on sgrt_install_path
if [ -d "$sgrt_install_path" ]; then
    echo ""
    echo "Directory '$sgrt_install_path' already exists. Exiting."
    echo ""
    exit 1
fi

#get local_path
echo ""
read -p "${bold}Please, enter the value for LOCAL_DRIVE_PATH (default: $LOCAL_DRIVE_PATH):${normal} " local_path
if [ -z "$local_path" ]; then
    local_path=$LOCAL_DRIVE_PATH
fi


#test
echo $SGRT_INSTALL_PATH
echo $sgrt_install_path
echo $local_path


#authenticate as sudo and become root
sudo -s <<EOF

# Now you are running as root

# Change to the desired directory and create a folder
cd /local/home/root
mkdir -p prova

# Exit from the root shell
exit

EOF

echo $SGRT_INSTALL_PATH
echo $sgrt_install_path
echo $local_path

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



