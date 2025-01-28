#!/bin/bash

CLI_NAME="hdev"
bold=$(tput bold)
normal=$(tput sgr0)

chmod_x() {
    path="$1"
    for file in "$path"/*.sh; do
        chmod +x "$file"
        mv "$file" "${file%.sh}"
    done
}

#installation constants
BASE_PATH="/opt"                                                                        #0  dialog
PACKAGES=("curl" "gh" "jq" "python3" "uncrustify")
REPO_NAME="hdev"
TMP_PATH="/tmp"

#constants (there are 21 as of 17.09.2024)
#ACAP_SERVERS_LIST                                                                      #1  dialog 2
#ASOC_SERVERS_LIST                                                                      #22 dialog 2.1
AVED_DRIVER_NAME="ami.ko"                                                               #23
AVED_PATH="/opt/amd/aved"                                                               #24 dialog 8.1.2
AVED_REPO="Xilinx/AVED"                                                                 #25
AVED_SMBUS_IP="smbus_v1_1-20240328"                                                     #26
AVED_TAG="amd_v80_gen5x8_24.1_20241002"                                                 #27
AVED_TOOLS_PATH="/usr/local/bin"                                                        #28 dialog 8.1.1
AVED_UUID="3907c6f088e5c23471ab99aae09a9928"                                            #29
#BUILD_SERVERS_LIST                                                                     #2
#COLOR_ACAP                                                                             #30
#COLOR_CPU                                                                              #31
#COLOR_FAILED                                                                           #32
#COLOR_FPGA                                                                             #33
#COLOR_GPU                                                                              #34
#COLOR_OFF                                                                              #35
#COLOR_PASSED                                                                           #36
#COLOR_XILINX                                                                           #37
EMAIL=""                                                                                #38 dialog
#FPGA_SERVERS_LIST                                                                      #3  dialog 3
GITHUB_CLI_PATH="/usr/bin"                                                              #4  dialog 10
#GPU_SERVERS_LIST                                                                       #5  dialog 4
LOCAL_PATH="/local/home/\$USER"                                                         #6  dialog 5
MTU_DEFAULT="1576"                                                                      #39
MTU_MAX="9000"                                                                          #40
MTU_MIN="1500"                                                                          #41
MY_DRIVERS_PATH="/tmp/devices_acap_fpga_drivers"                                        #7  dialog 6
MY_PROJECTS_PATH="/home/\$USER/my_projects"                                             #8  dialog 7
#NIC_SERVERS_LIST                                                                       #42
ONIC_DRIVER_COMMIT="1cf2578"                                                            #9
ONIC_DRIVER_NAME="onic.ko"                                                              #10
ONIC_DRIVER_REPO="Xilinx/open-nic-driver"                                               #11
ONIC_SHELL_COMMIT="8077751"                                                             #12
ONIC_SHELL_NAME="open_nic_shell.bit"                                                    #13
ONIC_SHELL_REPO="Xilinx/open-nic-shell"                                                 #14
ROCM_PATH="/opt/rocm"                                                                   #15 dialog 9
UPDATES_PATH="/tmp"                                                                     #16 dialog 11
#VIRTUALIZED_SERVERS_LIST                                                               #17 dialog 1 [UNUSED]
VRT_REPO="fpgasystems/vrt"                                                              #43
VRT_TAG="amd_v80_gen5x8_24.1_20241002"                                                  #44
XDP_BPFTOOL_COMMIT="687e7f0"                                                            #45
XDP_BPFTOOL_REPO="libbpf/bpftool"                                                       #46
XDP_LIBBPF_COMMIT="20c0a9e"                                                             #47
XDP_LIBBPF_REPO="libbpf/libbpf"                                                         #48
XILINX_PLATFORMS_PATH="/opt/xilinx/platforms"                                           #18 dialog 8.1
XILINX_TOOLS_PATH="/tools/Xilinx"                                                       #19 dialog 8.2
XILINXD_LICENSE_FILE="2100@my-license-server.ethz.ch:2101@my-license-server.ethz.ch"    #20 dialog 8.3
XRT_PATH="/opt/xilinx/xrt"                                                              #21 dialog 8.4

#derived
MAIN_BRANCH_URL="https://api.github.com/repos/fpgasystems/$REPO_NAME/commits/main"
MY_PROJECTS_PATH="/home/\$USER/${REPO_NAME}_projects"
REPO_URL="https://github.com/fpgasystems/$REPO_NAME.git"

#check if the user has sudo capabilities
if ! sudo -n true 2>/dev/null; then
    echo ""
    echo "Sorry, this command requires sudo capabilities."
    echo ""
    exit 1
fi

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

echo ""
echo "${bold}${REPO_NAME}_install${normal}"

#check on packages
for package in "${PACKAGES[@]}"; do
    if ! which "$package" > /dev/null 2>&1; then
        echo  ""
        echo "Please, install a valid $package version."
        echo  ""
        exit 1
    fi
done

#get base_path
echo ""
echo -n "${bold}Please, enter a non-existing installation path (default: $BASE_PATH):${normal} "
while true; do
    read -p "" base_path
    #assign to default if empty
    if [ -z "$base_path" ]; then
        base_path=$BASE_PATH
    fi
    #the installation destination should not exist
    if [ -d "$base_path/$REPO_NAME" ]; then
        echo ""
        echo "Please, enter a non-existing installation path"
        #echo ""
    else
        echo ""
        echo "HDEV will be installed in ${bold}$base_path/$REPO_NAME${normal}"
        break
    fi
done

#get email
echo ""
echo -n "${bold}Please, enter a valid email for the person in charge of $REPO_NAME:${normal} "
while true; do
    read -p "" email
    # Check if the email is not empty and matches a valid email format
    if [[ -n "$email" && "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        break
    fi
done

#derive paths
#api_path=$base_path/$REPO_NAME/api
cli_path=$base_path/$REPO_NAME/cli
templates_path=$base_path/$REPO_NAME/templates

#set VIRTUALIZED_SERVERS_LIST - dialog 1
#echo ""
#echo "${bold}Is $hostname a virtualized server (y/n)?:${normal}"
#virtualized_server=""
#while true; do
#    read -p "" yn
#    case $yn in
#        "y")
#            virtualized_server=$hostname
#            break
#            ;;
#        "n")
#            break
#            ;;
#    esac
#done

#set NIC_SERVERS_LIST - dialog X 
echo ""
echo "${bold}Does $hostname have any NIC mounted on it (y/n)?:${normal}" 
nic_server=""
while true; do
    read -p "" yn
    case $yn in
        "y") 
            nic_server=$hostname
            break
            ;;
        "n")
            break
            ;;
    esac
done

#set ACAP_SERVERS_LIST - dialog 2 
echo ""
echo "${bold}Does $hostname have any ACAP (i.e., Alveo VCK5000) mounted on it (y/n)?:${normal}" 
acap_server=""
while true; do
    read -p "" yn
    case $yn in
        "y") 
            acap_server=$hostname
            break
            ;;
        "n")
            break
            ;;
    esac
done

#set ASOC_SERVERS_LIST - dialog 2.1 
echo ""
echo "${bold}Does $hostname have any ASOC (i.e., Alveo V80) mounted on it (y/n)?:${normal}" 
asoc_server=""
while true; do
    read -p "" yn
    case $yn in
        "y") 
            asoc_server=$hostname
            break
            ;;
        "n")
            break
            ;;
    esac
done

#set FPGA_SERVERS_LIST - dialog 3
echo ""
echo "${bold}Does $hostname have any FPGA (i.e., Alveo U55C) mounted on it (y/n)?:${normal}" 
fpga_server=""
while true; do
    read -p "" yn
    case $yn in
        "y") 
            fpga_server=$hostname
            break
            ;;
        "n")
            break
            ;;
    esac
done

#set GPU_SERVERS_LIST - dialog 4
echo ""
echo "${bold}Does $hostname have any GPU mounted on it (y/n)?:${normal}" 
gpu_server=""
while true; do
    read -p "" yn
    case $yn in
        "y") 
            gpu_server=$hostname
            break
            ;;
        "n")
            break
            ;;
    esac
done

#set BUILD_SERVERS_LIST (the server does not have any ACAP, FPGA, or GPU)
build_server=""
if [ "$acap_server" = "" ] && [ "$asoc_server" = "" ] && [ "$fpga_server" = "" ] && [ "$gpu_server" = "" ]; then
    build_server=$hostname
fi

#get local_path - dialog 5
echo ""
read -p "${bold}Please, enter the value for LOCAL_PATH (default: $LOCAL_PATH):${normal} " local_path
if [ -z "$local_path" ]; then
    local_path=$LOCAL_PATH
    echo $local_path
fi

#get my_drivers_path - dialog 6
echo ""
read -p "${bold}Please, enter the value for MY_DRIVERS_PATH (default: $MY_DRIVERS_PATH):${normal} " my_drivers_path
if [ -z "$my_drivers_path" ]; then
    my_drivers_path=$MY_DRIVERS_PATH
    echo $my_drivers_path
fi

#get my_projects_path - dialog 7
echo ""
read -p "${bold}Please, enter the value for MY_PROJECTS_PATH (default: $MY_PROJECTS_PATH):${normal} " my_projects_path
if [ -z "$my_projects_path" ]; then
    my_projects_path=$MY_PROJECTS_PATH
    echo $my_projects_path
fi

#get xilinx_platforms_path - dialog 8
xilinx_platforms_path=""
xilinx_tools_path=""
xrt_path=""
xilinx_tools_path_exists="0"
if [ "$acap_server" = "$hostname" ] || [ "$fpga_server" = "$hostname" ]; then
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
        xilinx_tools_path_exists="1"
        echo $xilinx_tools_path
    fi

    #get xilinxd_license_file
    echo ""
    echo -n "${bold}Please, enter the value for XILINXD_LICENSE_FILE (example: $XILINXD_LICENSE_FILE):${normal} "
    while true; do
        read -p "" xilinxd_license_file
        #check if not empty
        if [ -z "$xilinxd_license_file" ]; then
            echo ""
            echo "Please, enter a valid value for XILINXD_LICENSE_FILE"
        else
            # Validate format
            if [[ "$xilinxd_license_file" =~ ^[[:digit:]]+@[[:alnum:].-]+(:[[:digit:]]+@[[:alnum:].-]+)?$ ]]; then
                # Valid format
                break
            else
                echo ""
                echo "Please, enter a valid value for XILINXD_LICENSE_FILE" 
            fi
        fi
    done

    #get xrt_path
    echo ""
    read -p "${bold}Please, enter the value for XRT_PATH (default: $XRT_PATH):${normal} " xrt_path
    if [ -z "$xrt_path" ]; then
        xrt_path=$XRT_PATH
        echo $xrt_path
    fi
fi

#dialog 8.1
aved_tools_path=""
aved_path=""
if [ "$asoc_server" = "$hostname" ]; then
    if ["$xilinx_tools_path_exists" = "0" ]; then
        #get xilinx_tools_path
        echo ""
        read -p "${bold}Please, enter the value for XILINX_TOOLS_PATH (default: $XILINX_TOOLS_PATH):${normal} " xilinx_tools_path
        if [ -z "$xilinx_tools_path" ]; then
            xilinx_tools_path=$XILINX_TOOLS_PATH
            echo $xilinx_tools_path
        fi

        #get xilinxd_license_file
        echo ""
        echo -n "${bold}Please, enter the value for XILINXD_LICENSE_FILE (example: $XILINXD_LICENSE_FILE):${normal} "
        while true; do
            read -p "" xilinxd_license_file
            #check if not empty
            if [ -z "$xilinxd_license_file" ]; then
                echo ""
                echo "Please, enter a valid value for XILINXD_LICENSE_FILE"
            else
                # Validate format
                if [[ "$xilinxd_license_file" =~ ^[[:digit:]]+@[[:alnum:].-]+(:[[:digit:]]+@[[:alnum:].-]+)?$ ]]; then
                    # Valid format
                    break
                else
                    echo ""
                    echo "Please, enter a valid value for XILINXD_LICENSE_FILE" 
                fi
            fi
        done
    fi

    #get aved_tools_path
    echo ""
    read -p "${bold}Please, enter the value for AVED_TOOLS_PATH (default: $AVED_TOOLS_PATH):${normal} " aved_tools_path
    if [ -z "$aved_tools_path" ]; then
        aved_tools_path=$AVED_TOOLS_PATH
        echo $aved_tools_path
    fi

    #get aved_path
    echo ""
    read -p "${bold}Please, enter the value for AVED_PATH (default: $AVED_PATH):${normal} " aved_path
    if [ -z "$aved_path" ]; then
        aved_path=$AVED_PATH
        echo $aved_path
    fi
fi

#get rocm_path - dialog 9
rocm_path=""
if [ "$gpu_server" = "$hostname" ]; then
    echo ""
    read -p "${bold}Please, enter the value for ROCM_PATH (default: $ROCM_PATH):${normal} " rocm_path
    if [ -z "$rocm_path" ]; then
        rocm_path=$ROCM_PATH
        echo $rocm_path
    fi
fi

#get github_cli_path - dialog 10
echo ""
read -p "${bold}Please, enter the value for GITHUB_CLI_PATH (default: $GITHUB_CLI_PATH):${normal} " github_cli_path
if [ -z "$github_cli_path" ]; then
    github_cli_path=$GITHUB_CLI_PATH
    echo $github_cli_path
fi

#get updates_path - dialog 11
echo ""
read -p "${bold}Please, enter the value for UPDATES_PATH (default: $UPDATES_PATH):${normal} " updates_path
if [ -z "$updates_path" ]; then
    updates_path=$UPDATES_PATH
    echo $updates_path
fi

#define temporal installation path
HDEV_INSTALL_TMP_PATH=$TMP_PATH/hdev_install

if [ ! -d "$HDEV_INSTALL_TMP_PATH" ]; then
    mkdir -p "$HDEV_INSTALL_TMP_PATH"
else
    echo ""
    echo "The directory ${bold}HDEV_INSTALL_TMP_PATH${normal} is already existing. Please, remove it and try again!"
    echo ""
    exit
fi

#checkout hdev
echo ""
git clone $REPO_URL $HDEV_INSTALL_TMP_PATH/$REPO_NAME

#get last commit date on the remote
remote_commit_date=$(curl -s $MAIN_BRANCH_URL | jq -r '.commit.committer.date')

#get commit ID
cd $HDEV_INSTALL_TMP_PATH/$REPO_NAME
remote_commit_id=$(git rev-parse --short HEAD)

#hdev cleanup
rm -rf $HDEV_INSTALL_TMP_PATH/$REPO_NAME/*.md
rm -rf $HDEV_INSTALL_TMP_PATH/$REPO_NAME/*.png
rm -rf $HDEV_INSTALL_TMP_PATH/$REPO_NAME/LICENSE
#docs
rm -rf $HDEV_INSTALL_TMP_PATH/$REPO_NAME/docs
#examples
rm -rf $HDEV_INSTALL_TMP_PATH/$REPO_NAME/examples
#playbooks
rm -rf $HDEV_INSTALL_TMP_PATH/$REPO_NAME/playbooks
#trash
if [ -d "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/trash" ]; then
    rm -rf $HDEV_INSTALL_TMP_PATH/$REPO_NAME/trash
fi
#hdev/api docs
#rm -rf $HDEV_INSTALL_TMP_PATH/$REPO_NAME/api/*.md
#rm -rf $HDEV_INSTALL_TMP_PATH/$REPO_NAME/api/manual
#hdev/cli docs
rm -rf $HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/*.md
rm -rf $HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/manual
#overleaf
rm -rf $HDEV_INSTALL_TMP_PATH/$REPO_NAME/overleaf*
#hacc-validation
rm -rf $HDEV_INSTALL_TMP_PATH/$REPO_NAME/hacc-validation

#update COMMIT and COMMIT_DATE
echo $remote_commit_id > $HDEV_INSTALL_TMP_PATH/$REPO_NAME/COMMIT
echo $remote_commit_date > $HDEV_INSTALL_TMP_PATH/$REPO_NAME/COMMIT_DATE

#move update
sudo mv $HDEV_INSTALL_TMP_PATH/$REPO_NAME/update.sh $HDEV_INSTALL_TMP_PATH/$REPO_NAME/update

#manage scripts
chmod_x $HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli
chmod_x $HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/build
chmod_x $HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/common
chmod_x $HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/enable
chmod_x $HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/get
chmod_x $HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/new
chmod_x $HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/program
chmod_x $HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/run
chmod_x $HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/set
chmod_x $HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/validate

#constants
echo -n "$acap_server" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ACAP_SERVERS_LIST"                #1
echo -n "$asoc_server" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ASOC_SERVERS_LIST"                #22  
echo -n "$AVED_DRIVER_NAME" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/AVED_DRIVER_NAME"            #23
echo -n "$aved_path" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/AVED_PATH"                          #24
echo -n "$AVED_REPO" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/AVED_REPO"                          #25
echo -n "$AVED_SMBUS_IP" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/AVED_SMBUS_IP"                  #26
echo -n "$AVED_TAG" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/AVED_TAG"                            #27
echo -n "$aved_tools_path" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/AVED_TOOLS_PATH"              #28
echo -n "$AVED_UUID" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/AVED_UUID"                          #29
echo -n "$build_server" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/BUILD_SERVERS_LIST"              #2
echo "'\033[38;5;104m'" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/COLOR_ACAP"                      #30
echo "'\033[38;5;111m'" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/COLOR_CPU"                       #31
echo "'\033[0;31m'" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/COLOR_FAILED"                        #32
echo "'\033[38;5;177m'" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/COLOR_FPGA"                      #33
echo "'\033[38;5;38m'" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/COLOR_GPU"                        #34
echo "'\033[0m'" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/COLOR_OFF"                              #35
echo "'\033[0;32m'" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/COLOR_PASSED"                        #36
echo "'\033[38;5;197m'" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/COLOR_XILINX"                    #37
echo -n "$email" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/EMAIL"                                  #38
echo -n "$fpga_server" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/FPGA_SERVERS_LIST"                #3
echo -n "$github_cli_path" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/GITHUB_CLI_PATH"              #4
echo -n "$gpu_server" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/GPU_SERVERS_LIST"                  #5
echo -n "$local_path" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/LOCAL_PATH"                        #6
echo -n "$MTU_DEFAULT" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/MTU_DEFAULT"                      #39
echo -n "$MTU_MAX" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/MTU_MAX"                              #40
echo -n "$MTU_MIN" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/MTU_MIN"                              #41
echo -n "$my_drivers_path" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/MY_DRIVERS_PATH"              #7
echo -n "$my_projects_path" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/MY_PROJECTS_PATH"            #8
echo -n "$nic_server" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/NIC_SERVERS_LIST"                  #42
echo -n "$ONIC_DRIVER_COMMIT" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ONIC_DRIVER_COMMIT"        #9
echo -n "$ONIC_DRIVER_NAME" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ONIC_DRIVER_NAME"            #10
echo -n "$ONIC_DRIVER_REPO" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ONIC_DRIVER_REPO"            #11
echo -n "$ONIC_SHELL_COMMIT" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ONIC_SHELL_COMMIT"          #12
echo -n "$ONIC_SHELL_NAME" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ONIC_SHELL_NAME"              #13
echo -n "$ONIC_SHELL_REPO" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ONIC_SHELL_REPO"              #14
echo -n "$rocm_path" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ROCM_PATH"                          #15
echo -n "$updates_path" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/UPDATES_PATH"                    #16
#echo -n "$virtualized_server" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/VIRTUALIZED_SERVERS_LIST" #17
echo -n "$VRT_REPO" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/VRT_REPO"                            #43
echo -n "$VRT_TAG" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/VRT_TAG"                              #44
echo -n "$XDP_BPFTOOL_COMMIT" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/XDP_BPFTOOL_COMMIT"        #45
echo -n "$XDP_BPFTOOL_REPO" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/XDP_BPFTOOL_REPO"            #46
echo -n "$XDP_LIBBPF_COMMIT" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/XDP_LIBBPF_COMMIT"          #47
echo -n "$XDP_LIBBPF_REPO" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/XDP_LIBBPF_REPO"              #48
echo -n "$xilinx_platforms_path" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/XILINX_PLATFORMS_PATH"  #18
echo -n "$xilinx_tools_path" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/XILINX_TOOLS_PATH"          #19
IFS=':' read -ra licenses <<< "$xilinxd_license_file"                                                       #20
for license in "${licenses[@]}"; do
    echo "$license" >> "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/XILINXD_LICENSE_FILE"
done
echo -n "$xrt_path" > "$HDEV_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/XRT_PATH"                            #21

#copy to base_path
sudo mv $HDEV_INSTALL_TMP_PATH/$REPO_NAME $base_path
sudo chown -R root:root $base_path/$REPO_NAME

#adding to profile.d (system-wide $PATH)
echo "PATH=\$PATH:$cli_path" | sudo tee /etc/profile.d/$CLI_NAME.sh > /dev/null

#copying hdev_completion
sudo mv $base_path/$REPO_NAME/cli/$CLI_NAME"_completion" /usr/share/bash-completion/completions/$CLI_NAME
sudo chown root:root /usr/share/bash-completion/completions/$CLI_NAME

#export API, CLI, and TEMPLATES_PATH
if ! grep -qF "export CLI_PATH=${cli_path}" /etc/bash.bashrc; then
    #echo "export CLI_PATH=${api_path}" | sudo tee -a /etc/bash.bashrc > /dev/null
    echo "export CLI_PATH=${cli_path}" | sudo tee -a /etc/bash.bashrc > /dev/null
    echo "export CLI_PATH=${templates_path}" | sudo tee -a /etc/bash.bashrc > /dev/null
fi

#remove folder
sudo rm -rf $HDEV_INSTALL_TMP_PATH

#print
echo ""
echo "$REPO_NAME was installed in ${bold}$base_path (commit ID: $remote_commit_id)!${normal}"
echo ""