#!/bin/bash

EXTERNAL_DIR="backend/ext"

################# CONFIGURATION #################

CSPICE_URL="https://naif.jpl.nasa.gov/pub/naif/toolkit//C/PC_Linux_GCC_64bit/packages/cspice.tar.Z"
CSPICE_DIR="$EXTERNAL_DIR/cspice"
CSPICE_ARCHIVE="$EXTERNAL_DIR/cspice.tar.Z"

HERA_URL="https://s2e2.cosmos.esa.int/bitbucket/scm/spice_kernels/hera.git"
HERA_DIR="$EXTERNAL_DIR/hera"

SCRIPT_PATH="$(dirname "$(realpath "$0")")"
PROJECT_PATH="$(dirname "$SCRIPT_PATH")"

KERNELS_PATH="$PROJECT_PATH/$EXTERNAL_DIR/hera/kernels"
META_KERNEL_DIR="$PROJECT_PATH/$EXTERNAL_DIR/hera/kernels/mk"

PACKAGE_LIST="tar ncompress libcurl4-openssl-dev g++ libboost-all-dev ccache"

INSTALLED=0



################# CHECKING PACKAGES ################

echo -e "############### CHECKING PACKAGES ###############"
echo
echo "sudo apt install $PACKAGE_LIST"
echo
sudo apt install $PACKAGE_LIST -y
echo



################# CHECKING CSPICE TOOLKIT INSTALLATION ################

echo -e "\n############### CSPICE TOOLKIT INSTALLATION ###############\n"
echo "Checking CSPICE TOOLKIT installation ..."
if [ ! -d "$CSPICE_DIR" ]; then
    echo "Downloading " "$CSPICE_URL" "..."
    wget -q --show-progress "$CSPICE_URL" -O "$CSPICE_ARCHIVE"
    TOTAL_FILES=$(tar -tZf "$CSPICE_ARCHIVE" | wc -l)
    COUNT=0
    echo "Extracting CSPICE TOOLKIT ..."
    cd $EXTERNAL_DIR
    tar -vxZf "cspice.tar.Z" | while read file;
    do
        COUNT=$((COUNT + 1))
        echo -ne "\r\033[KExtracted: $COUNT / $TOTAL_FILES files"
    done
    # mv cspice backend/external/cspice
    echo -ne "\r\033[KExtraction completed! $TOTAL_FILES / $TOTAL_FILES\n"
    cd ..
    cd ..
    echo "Cleaning up ..."
    rm "$CSPICE_ARCHIVE"
    echo "CSPICE TOOLKIT installed successfully!"
else
    echo "CSPICE TOOLKIT is already installed!"
    INSTALLED=1
fi



################# CHECKING HERA KERNELS INSTALLATION ################

echo -e "\n############### HERA KERNELS INSTALLATION ###############\n"
echo "Checking HERA KERNELS installation ..."
if [ ! -f "$HERA_DIR/version" ]; then
    echo $(pwd)
    cd "$EXTERNAL_DIR"
    git clone --depth 1 "$HERA_URL"
    rm -rf "hera/.*"
    cd ..
    cd ..
    echo "HERA KERNELS installed successfully!"
else
    echo "HERA KERNELS are already installed!"
    INSTALLED=1
fi



################# SETTING UP PROJECT PATHS ################

echo -e "\n############### PROJECT PATH SETUP ###############\n"

echo "Setting up KERNEL PATHS in the metakernel files ..."
find "$META_KERNEL_DIR" -type f -name "*.tm" -exec sed -i "s|\.\.|$KERNELS_PATH|g" {} +
echo -e "KERNEL PATHS are all set up in the metakernel files!\n"

echo "Setting up PROJECT_PATH in the kernels.h file ..."
sed -i "s|#define PROJECT_PATH \".*\"|#define PROJECT_PATH \"$PROJECT_PATH\"|" "$PROJECT_PATH/backend/inc/kernels.h"
echo "PROJECT_PATHS are all set up in the kernels.h file!"



################# UPDAE DEPENDENCIES IF THEY WHERE ALREADY INSTALLED BEFORE RUNNING THIS SCRIPT ################

if [ "$INSTALLED" -eq 1 ]; then
    echo -e "\n############### SOME DEPENDENCIES WHERE ALREADY INSTALLED! ###############"
    echo
    read -p "Do you want to reinstall them? This might take some time. (Y/N): " answer
    case "$answer" in
        *[Yy]* )
            rm -rf "$CSPICE_DIR" "$HERA_DIR" "$UWS_DIR"
            clear
            exec $0
            exit 0
        ;;
        * )
            echo "Exiting..."
            exit 0
        ;;
    esac
else
    echo -e "\n############### ALL DEPENDENCIES ARE UP TO DATE! ###############\n"
fi
