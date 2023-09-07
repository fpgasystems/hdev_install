#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

remove_sh() {
    path="$1"
    for file in "$path"/*.sh; do
        mv "$file" "${file%.sh}"
    done
}

#get RUN_PATH
RUN_PATH="$(readlink -f "$0")"
RUN_PATH=$(dirname "$RUN_PATH")

#default constants
SGRT_INSTALL_PATH="/opt/sgrt"
MPICH_PATH="/opt/mpich"
MY_DRIVERS_PATH="/local/home/\$USER"
MY_PROJECTS_PATH="/home/\$USER/sgrt_projects"
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
read -p "${bold}Please, enter the value for MPICH_PATH (default: $MPICH_PATH):${normal} " mpich_path
if [ -z "$mpich_path" ]; then
    mpich_path=$MPICH_PATH
    echo $mpich_path
fi

#get my_drivers_path
echo ""
read -p "${bold}Please, enter the value for MY_DRIVERS_PATH (default: $MY_DRIVERS_PATH):${normal} " my_drivers_path
if [ -z "$my_drivers_path" ]; then
    my_drivers_path=$MY_DRIVERS_PATH
    echo $my_drivers_path
fi

#get my_projects_path
echo ""
read -p "${bold}Please, enter the value for MY_PROJECTS_PATH (default: $MY_PROJECTS_PATH):${normal} " my_projects_path
if [ -z "$my_projects_path" ]; then
    my_projects_path=$MY_PROJECTS_PATH
    echo $my_projects_path
fi

#get rocm_path
echo ""
read -p "${bold}Please, enter the value for ROCM_PATH (default: $ROCM_PATH):${normal} " rocm_path
if [ -z "$rocm_path" ]; then
    rocm_path=$ROCM_PATH
    echo $rocm_path
fi

#get xilinx_platforms_path
echo ""
read -p "${bold}Please, enter the value for XILINX_PLATFORMS_PATH (default: $XILINX_PLATFORMS_PATH):${normal} " xilinx_platforms_path
if [ -z "$xilinx_platforms_path" ]; then
    xilinx_platforms_path=$XILINX_PLATFORMS_PATH
    echo $xilinx_platforms_path
fi

#get xilinx_tools_path
echo ""
read -p "${bold}Please, enter the value for XILINX_TOOLS_PATH (default: $XILINX_TOOLS_PATH):${normal} " xilinx_tools_path
if [ -z "$xilinx_tools_path" ]; then
    xilinx_tools_path=$XILINX_TOOLS_PATH
    echo $xilinx_tools_path
fi

#get xrt_path
echo ""
read -p "${bold}Please, enter the value for XRT_PATH (default: $XRT_PATH):${normal} " xrt_path
if [ -z "$xrt_path" ]; then
    xrt_path=$XRT_PATH
    echo $xrt_path
fi

#checkout sgrt
cd $RUN_PATH
echo ""
git clone https://github.com/fpgasystems/sgrt.git

#sgrt cleanup
rm $RUN_PATH/sgrt/*.md
rm $RUN_PATH/sgrt/*.png
rm $RUN_PATH/sgrt/LICENSE
#docs
rm -rf $RUN_PATH/sgrt/docs
#examples
rm -rf $RUN_PATH/sgrt/examples
#playbooks
rm -rf $RUN_PATH/sgrt/playbooks
#trash
if [ -d "$RUN_PATH/sgrt/trash" ]; then
    rm -rf $RUN_PATH/sgrt/trash
fi
#sgrt/api docs
rm $RUN_PATH/sgrt/api/*.md
rm -rf $RUN_PATH/sgrt/api/manual
#sgrt/cli docs
rm $RUN_PATH/sgrt/cli/*.md
rm -rf $RUN_PATH/sgrt/cli/manual
#sgrt/cli completion
rm $RUN_PATH/sgrt/cli/sgutil_completion.sh

#rename cli scripts
#mv $RUN_PATH/sgrt/cli/examine.sh $RUN_PATH/sgrt/cli/examine
#mv $RUN_PATH/sgrt/cli/reboot.sh $RUN_PATH/sgrt/cli/reboot
#mv $RUN_PATH/sgrt/cli/sgutil.sh $RUN_PATH/sgrt/cli/sgutil

remove_sh $RUN_PATH/sgrt/cli
remove_sh $RUN_PATH/sgrt/cli/build
remove_sh $RUN_PATH/sgrt/cli/common
remove_sh $RUN_PATH/sgrt/cli/enable
remove_sh $RUN_PATH/sgrt/cli/get
remove_sh $RUN_PATH/sgrt/cli/new
remove_sh $RUN_PATH/sgrt/cli/program
remove_sh $RUN_PATH/sgrt/cli/run
remove_sh $RUN_PATH/sgrt/cli/set
remove_sh $RUN_PATH/sgrt/cli/validate

#fill up files
echo -n "$mpich_path" > "$RUN_PATH/sgrt/cli/constants/MPICH_PATH"
echo -n "$my_drivers_path" > "$RUN_PATH/sgrt/cli/constants/MY_DRIVERS_PATH"
echo -n "$my_projects_path" > "$RUN_PATH/sgrt/cli/constants/MY_PROJECTS_PATH"
echo -n "$rocm_path" > "$RUN_PATH/sgrt/cli/constants/ROCM_PATH"
echo -n "$VIVADO_DEVICES_MAX" > "$RUN_PATH/sgrt/cli/constants/VIVADO_DEVICES_MAX" #it is fixed for now
echo -n "$xilinx_platforms_path" > "$RUN_PATH/sgrt/cli/constants/XILINX_PLATFORMS_PATH"
echo -n "$xilinx_tools_path" > "$RUN_PATH/sgrt/cli/constants/XILINX_TOOLS_PATH"
echo -n "$xrt_path" > "$RUN_PATH/sgrt/cli/constants/XRT_PATH"


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



