#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#default constants
SGRT_INSTALL_PATH="/opt/sgrt"
LOCAL_PATH="/local/home/\$USER"
MPICH_PATH="/opt/mpich"
MY_PROJECTS_PATH="/home/\$USER/my_projects"
ROCM_PATH="/opt/rocm"
VIVADO_DEVICES_MAX="1"
XILINX_PLATFORMS_PATH="/opt/xilinx/platforms"
XILINX_TOOLS_PATH="/tools/Xilinx"
XRT_PATH="/opt/xilinx/xrt"

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
if [ "$EUID" -ne 0 ]; then
    echo ""
    echo "This script must be run with sudo. Please use 'sudo $0' to execute it."
    echo ""
    exit 1
fi

#get sgrt_install_path
echo ""
read -p "${bold}Please, enter the installation path (default: $SGRT_INSTALL_PATH):${normal} " sgrt_install_path
echo ""
if [ -z "$sgrt_install_path" ]; then
    sgrt_install_path=$SGRT_INSTALL_PATH
fi

#get local_path
echo ""
read -p "${bold}Please, enter the value for LOCAL_PATH (default: $LOCAL_PATH):${normal} " local_path
echo ""
if [ -z "$local_path" ]; then
    local_path=$LOCAL_PATH
fi


#test
echo $SGRT_INSTALL_PATH
echo $sgrt_install_path
echo $local_path

exit

#checkout sgrt

#cleanup sgrt

#move sgrt

#derive CLI path
CLI_PATH="$sgrt_install_path/cli"

#save constants
echo "$local_path" > "$CLI_PATH/constants/LOCAL_PATH"



