#!/bin/bash

CLI_NAME="sgutil"
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
BASE_PATH="/opt"                                                                        #   dialog
PACKAGES=("curl" "gh" "jq" "python3" "uncrustify")
REPO_NAME="sgrt"
TMP_PATH="/tmp"

#constants (there are 21 as of 17.09.2024)
#ACAP_SERVERS_LIST                                                                      #1  dialog 2
#BUILD_SERVERS_LIST                                                                     #2
#FPGA_SERVERS_LIST                                                                      #3  dialog 3
GITHUB_CLI_PATH="/usr/bin"                                                              #4  dialog 10
#GPU_SERVERS_LIST                                                                       #5  dialog 4
LOCAL_PATH="/local/home/\$USER"                                                         #6  dialog 5
MY_DRIVERS_PATH="/tmp/devices_acap_fpga_drivers"                                        #7  dialog 6
MY_PROJECTS_PATH="/home/\$USER/my_projects"                                             #8  dialog 7
ONIC_DRIVER_COMMIT="1cf2578"                                                            #9
ONIC_DRIVER_NAME="onic.ko"                                                              #10
ONIC_DRIVER_REPO="Xilinx/open-nic-driver"                                               #11
ONIC_SHELL_COMMIT="8077751"                                                             #12
ONIC_SHELL_NAME="open_nic_shell.bit"                                                    #13
ONIC_SHELL_REPO="Xilinx/open-nic-shell"                                                 #14
ROCM_PATH="/opt/rocm"                                                                   #15 dialog 9
UPDATES_PATH="/tmp"                                                                     #16 dialog 11
#VIRTUALIZED_SERVERS_LIST                                                               #17 dialog 1
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
        echo "SGRT will be installed in ${bold}$base_path/$REPO_NAME${normal}"
        break
    fi
done

#derive paths
api_path=$base_path/$REPO_NAME/api
cli_path=$base_path/$REPO_NAME/cli
templates_path=$base_path/$REPO_NAME/templates

#set VIRTUALIZED_SERVERS_LIST - dialog 1
echo ""
echo "${bold}Is $hostname a virtualized server (y/n)?:${normal}"
virtualized_server=""
while true; do
    read -p "" yn
    case $yn in
        "y")
            virtualized_server=$hostname
            break
            ;;
        "n")
            break
            ;;
    esac
done

#set ACAP_SERVERS_LIST - dialog 2 
echo ""
echo "${bold}Does $hostname have any ACAP mounted on it (y/n)?:${normal}" 
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

#set FPGA_SERVERS_LIST - dialog 3
echo ""
echo "${bold}Does $hostname have any FPGA mounted on it (y/n)?:${normal}" 
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
if [ "$acap_server" = "" ] && [ "$fpga_server" = "" ] && [ "$gpu_server" = "" ]; then
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
SGRT_INSTALL_TMP_PATH=$TMP_PATH/sgrt_install

if [ ! -d "$SGRT_INSTALL_TMP_PATH" ]; then
    mkdir -p "$SGRT_INSTALL_TMP_PATH"
else
    echo ""
    echo "The directory ${bold}SGRT_INSTALL_TMP_PATH${normal} is already existing. Please, remove it and try again!"
    echo ""
    exit
fi

#checkout sgrt
echo ""
git clone $REPO_URL $SGRT_INSTALL_TMP_PATH/$REPO_NAME

#get last commit date on the remote
remote_commit_date=$(curl -s $MAIN_BRANCH_URL | jq -r '.commit.committer.date')

#get commit ID
cd $SGRT_INSTALL_TMP_PATH/$REPO_NAME
remote_commit_id=$(git rev-parse --short HEAD)

#sgrt cleanup
rm $SGRT_INSTALL_TMP_PATH/$REPO_NAME/*.md
rm $SGRT_INSTALL_TMP_PATH/$REPO_NAME/*.png
rm $SGRT_INSTALL_TMP_PATH/$REPO_NAME/LICENSE
#docs
rm -rf $SGRT_INSTALL_TMP_PATH/$REPO_NAME/docs
#examples
rm -rf $SGRT_INSTALL_TMP_PATH/$REPO_NAME/examples
#playbooks
rm -rf $SGRT_INSTALL_TMP_PATH/$REPO_NAME/playbooks
#trash
if [ -d "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/trash" ]; then
    rm -rf $SGRT_INSTALL_TMP_PATH/$REPO_NAME/trash
fi
#sgrt/api docs
rm $SGRT_INSTALL_TMP_PATH/$REPO_NAME/api/*.md
rm -rf $SGRT_INSTALL_TMP_PATH/$REPO_NAME/api/manual
#sgrt/cli docs
rm $SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/*.md
rm -rf $SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/manual
#overleaf
rm -rf $SGRT_INSTALL_TMP_PATH/$REPO_NAME/overleaf*
#hacc-validation
rm -rf $SGRT_INSTALL_TMP_PATH/$REPO_NAME/hacc-validation

#update COMMIT and COMMIT_DATE
echo $remote_commit_id > $SGRT_INSTALL_TMP_PATH/$REPO_NAME/COMMIT
echo $remote_commit_date > $SGRT_INSTALL_TMP_PATH/$REPO_NAME/COMMIT_DATE

#move update
sudo mv $SGRT_INSTALL_TMP_PATH/$REPO_NAME/update.sh $SGRT_INSTALL_TMP_PATH/$REPO_NAME/update

#manage scripts
chmod_x $SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli
chmod_x $SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/build
chmod_x $SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/common
chmod_x $SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/enable
chmod_x $SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/get
chmod_x $SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/new
chmod_x $SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/program
chmod_x $SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/run
chmod_x $SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/set
chmod_x $SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/validate

#constants
echo -n "$acap_server" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ACAP_SERVERS_LIST"                #1
echo -n "$build_server" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/BUILD_SERVERS_LIST"              #2
echo -n "$fpga_server" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/FPGA_SERVERS_LIST"                #3
echo -n "$github_cli_path" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/GITHUB_CLI_PATH"              #4
echo -n "$gpu_server" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/GPU_SERVERS_LIST"                  #5
echo -n "$local_path" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/LOCAL_PATH"                        #6
echo -n "$my_drivers_path" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/MY_DRIVERS_PATH"              #7
echo -n "$my_projects_path" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/MY_PROJECTS_PATH"            #8
echo -n "$ONIC_DRIVER_COMMIT" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ONIC_DRIVER_COMMIT"        #9
echo -n "$ONIC_DRIVER_NAME" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ONIC_DRIVER_NAME"            #10
echo -n "$ONIC_DRIVER_REPO" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ONIC_DRIVER_REPO"            #11
echo -n "$ONIC_SHELL_COMMIT" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ONIC_SHELL_COMMIT"          #12
echo -n "$ONIC_SHELL_NAME" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ONIC_SHELL_NAME"              #13
echo -n "$ONIC_SHELL_REPO" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ONIC_SHELL_REPO"              #14
echo -n "$rocm_path" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/ROCM_PATH"                          #15
echo -n "$updates_path" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/UPDATES_PATH"                    #16
echo -n "$virtualized_server" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/VIRTUALIZED_SERVERS_LIST"  #17
echo -n "$xilinx_platforms_path" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/XILINX_PLATFORMS_PATH"  #18
echo -n "$xilinx_tools_path" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/XILINX_TOOLS_PATH"          #19
IFS=':' read -ra licenses <<< "$xilinxd_license_file"                                                       #20
for license in "${licenses[@]}"; do
    echo "$license" >> "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/XILINXD_LICENSE_FILE"
done
echo -n "$xrt_path" > "$SGRT_INSTALL_TMP_PATH/$REPO_NAME/cli/constants/XRT_PATH"                            #21

#copy to base_path
sudo mv $SGRT_INSTALL_TMP_PATH/$REPO_NAME $base_path
sudo chown -R root:root $base_path/$REPO_NAME

#adding to profile.d (system-wide $PATH)
echo "PATH=\$PATH:$cli_path" | sudo tee /etc/profile.d/$CLI_NAME.sh > /dev/null

#copying sgutil_completion
sudo mv $base_path/$REPO_NAME/cli/$CLI_NAME"_completion" /usr/share/bash-completion/completions/$CLI_NAME
sudo chown root:root /usr/share/bash-completion/completions/$CLI_NAME

#export API, CLI, and TEMPLATES_PATH
if ! grep -qF "export CLI_PATH=${cli_path}" /etc/bash.bashrc; then
    echo "export CLI_PATH=${api_path}" | sudo tee -a /etc/bash.bashrc > /dev/null
    echo "export CLI_PATH=${cli_path}" | sudo tee -a /etc/bash.bashrc > /dev/null
    echo "export CLI_PATH=${templates_path}" | sudo tee -a /etc/bash.bashrc > /dev/null
fi

#remove folder
sudo rm -rf $SGRT_INSTALL_TMP_PATH

#print
echo ""
echo "$REPO_NAME was installed in ${bold}$base_path (commit ID: $remote_commit_id)!${normal}"
echo ""