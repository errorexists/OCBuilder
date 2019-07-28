#!/bin/bash

#  BuildScript.sh
#  OCBuilder
#
#  Created by Pavo on 7/28/19.
#  Copyright © 2019 Pavo. All rights reserved.

dialogTitle="OCBuilder"
# obtain the password from a dialog box
authPass=$(/usr/bin/osascript <<EOT
    tell application "System Events"
        activate
        repeat
            display dialog "This application requires administrator privileges. Please enter your administrator account password below to continue:" ¬
                default answer "" ¬
                with title "$dialogTitle" ¬
                with hidden answer ¬
                buttons {"Quit", "Continue"} default button 2
            if button returned of the result is "Quit" then
                return 1
                exit repeat
            else if the button returned of the result is "Continue" then
                set pswd to text returned of the result
                set usr to short user name of (system info)
                try
                    do shell script "echo test" user name usr password pswd with administrator privileges
                    return pswd
                    exit repeat
                end try
            end if
        end repeat
    end tell
EOT
)
# Abort if the Quit button was pressed
if [ "$authPass" == 1 ]
then
    /bin/echo "User aborted. Exiting..."
    exit 0
fi
# function that replaces sudo command
sudo () {
    /bin/echo $authPass | /usr/bin/sudo -S "$@"
}

sudo cp "${5}" /usr/local/bin
sudo cp "${6}" /usr/local/bin

BUILD_DIR="${1}/OCBuilder_Clone"
FINAL_DIR="${2}/OCBuilder_Completed"

buildrelease() {
    local name=$(pwd)
    local result=${name##*/}
    if [ result == "Lilu" ]
    then
        name=Lilu
    elif [ result == "WhateverGree"n ]
    then
        name=WhateverGreen
    elif [ result == "CPUFriend" ]
    then
        name=CPUFriend
    elif [ result == "AppleALC" ]
    then
        name=AppleALC
    elif [ result == "VirtualSMC" ]
    then
        name=VirtualSMC
    fi
    echo "************************************************************"
    echo "Compiling the latest commited Release version of $result."
    echo "************************************************************"
    xcodebuild -configuration Release
}

builddebug() {
    local name=$(pwd)
    local result=${name##*/}
    if [ result == "Lilu" ]
    then
        name=Lilu
    elif [ result == "WhateverGree"n ]
    then
        name=WhateverGreen
    elif [ result == "CPUFriend" ]
    then
        name=CPUFriend
    elif [ result == "AppleALC" ]
    then
        name=AppleALC
    elif [ result == "VirtualSMC" ]
    then
        name=VirtualSMC
    fi
    echo "************************************************************"
    echo "Compiling the latest commited Debug version of $result."
    echo "************************************************************"
    xcodebuild -configuration Debug
}

buildmactool() {
    local name=$(pwd)
    local result=${name##*/}
    if [ result == "OpenCorePkg" ]
    then
        name=OpenCorePkg
    elif [ result == "AptioFixPkg" ]
    then
        name=AptioFixPkg
    elif [ result == "AppleSupportPkg" ]
    then
        name=AppleSupportPkg
    elif [ result == "OpenCoreShell" ]
    then
        name=OpenCoreShell
    fi
    echo "********************************************************************"
    echo "Compiling the latest commited Release and Debug version of $result."
    echo "********************************************************************"
    ./macbuild.tool
}

updaterepo() {
    if [ ! -d "$2" ]; then
        git clone "$1" -b "$3" --depth=1 "$2" || exit 1
    fi
    pushd "$2" >/dev/null
    echo "*****************"
    echo "Updating Repo"
    echo "*****************"
    git pull >/dev/null 2>&1 || exit 1
    popd >/dev/null
}

repocheck() {
    local name=$(pwd)
    local result=${name##*/}
    if [ result == "Lilu" ]
    then
        name=Lilu
    elif [ result == "WhateverGreen" ]
    then
        name=WhateverGreen
    elif [ result == "CPUFriend" ]
    then
        name=CPUFriend
    elif [ result == "AppleALC" ]
    then
        name=AppleALC
    elif [ result == "VirtualSMC" ]
    then
        name=VirtualSMC
    fi
    localoutput="$(git log --pretty=%H ...refs/heads/master^ | head -n 1)"
    remoteoutput="$(git ls-remote origin -h refs/heads/master |cut -f1)"

    if [ "$localoutput" = "$remoteoutput" ]
    then
        local status=0
    else
        local status=1
    fi
    if [ $status = 0 ]
    then
        echo "******************************"
        echo "$result repo is up to date."
        echo "******************************"
    elif [ $status = 1 ]
    then
        echo "**********************************"
        echo "$result repo is not up to date."
        echo "**********************************"
        sleep 1
        echo "*****************"
        echo "Updating Repo"
        echo "*****************"
        git pull >/dev/null 2>&1 || exit 1
        builddebug
        buildrelease
    fi
}

pkgcheck() {
    local name=$(pwd)
    local result=${name##*/}
    if [ result == "OpenCorePkg" ]
    then
        name=OpenCorePkg
    elif [ result == "AptioFixPkg" ]
    then
        name=AptioFixPkg
    elif [ result == "AppleSupportPkg" ]
    then
        name=AppleSupportPkg
    elif [ result == "OpenCoreShell" ]
    then
        name=OpenCoreShell
    fi
    localoutput="$(git log --pretty=%H ...refs/heads/master^ | head -n 1)"
    remoteoutput="$(git ls-remote origin -h refs/heads/master |cut -f1)"

    if [ "$localoutput" = "$remoteoutput" ]
    then
        local status=0
    else
        local status=1
    fi
    if [ $status = 0 ]
    then
        echo "******************************"
        echo "$result repo is up to date."
        echo "******************************"
    elif [ $status = 1 ]
    then
        echo "*********************************"
        echo "$result repo is not up to date."
        echo "*********************************"
        sleep 1
        echo "*******************"
        echo "Updating Repo"
        echo "*******************"
        git pull >/dev/null 2>&1 || exit 1
        buildmactool
    fi
}

repoClone() {
    echo "********************************"
    echo "Cloning acidanthera's Repos."
    echo "********************************"
    repos[0]=https://github.com/acidanthera/Lilu.git
    repos[1]=https://github.com/acidanthera/WhateverGreen.git
    repos[2]=https://github.com/acidanthera/AppleALC.git
    repos[3]=https://github.com/acidanthera/CPUFriend.git
    repos[4]=https://github.com/acidanthera/VirtualSMC.git
    repos[5]=https://github.com/acidanthera/OpenCorePkg.git
    repos[6]=https://github.com/acidanthera/AptioFixPkg.git
    repos[7]=https://github.com/acidanthera/AppleSupportPkg.git
    repos[8]=https://github.com/acidanthera/OpenCoreShell.git

    dir[0]="${BUILD_DIR}/Lilu"
    dir[1]="${BUILD_DIR}/WhateverGreen"
    dir[2]="${BUILD_DIR}/AppleALC"
    dir[3]="${BUILD_DIR}/CPUFriend"
    dir[4]="${BUILD_DIR}/VirtualSMC"

    pkg[0]="${BUILD_DIR}/OpenCorePkg"
    pkg[1]="${BUILD_DIR}/AptioFixPkg"
    pkg[2]="${BUILD_DIR}/AppleSupportPkg"
    pkg[3]="${BUILD_DIR}/OpenCoreShell"

    cd "${BUILD_DIR}/"
    for i in "${repos[@]}"; do
        git clone $i >/dev/null 2>&1 || exit 1
    done

    cd "${BUILD_DIR}/Lilu"
    builddebug

    for x in "${dir[@]}"
    do
        cp -r "${BUILD_DIR}/Lilu/build/Debug/Lilu.kext" $x
        cd $x
        buildrelease
    done

    for x in "${pkg[@]}"
    do
        cd $x
        buildmactool
    done
}

makeDirectories() {
    if [ ! -d "${FINAL_DIR}/" ]
    then
        echo "**************************************************"
        echo "Creating Opencore EFI structure in ${FINAL_DIR}}."
        echo "**************************************************"
        mkdir "${FINAL_DIR}/"
    else
        echo "******************************************"
        echo "Updating current OCBuilder_Completed folder."
        echo "******************************************"
        rm -rf "${FINAL_DIR}/"
        mkdir "${FINAL_DIR}/"
    fi
}

copyBuildProducts() {
    echo "**********************************************************************"
    echo "Copying compiled products into EFI Structure folder in ${FINAL_DIR}."
    echo "**********************************************************************"
    cp "${BUILD_DIR}"/OpenCorePkg/Binaries/RELEASE/*.zip "${FINAL_DIR}/"
    cd "${FINAL_DIR}/"
    unzip *.zip >/dev/null 2>&1 || exit 1
    rm -rf *.zip >/dev/null 2>&1 || exit 1
    cp -r "${BUILD_DIR}/Lilu/build/Release/Lilu.kext" "${FINAL_DIR}/EFI/OC/Kexts"
    cp -r "${BUILD_DIR}/AppleALC/build/Release/AppleALC.kext" "${FINAL_DIR}/EFI/OC/Kexts"
    cp -r "${BUILD_DIR}"/VirtualSMC/build/Release/*.kext "${FINAL_DIR}/EFI/OC/Kexts"
    cp -r "${BUILD_DIR}/WhateverGreen/build/Release/WhateverGreen.kext" "${FINAL_DIR}/EFI/OC/Kexts"
    cp -r "${BUILD_DIR}/CPUFriend/build/Release/CPUFriend.kext" "${FINAL_DIR}/EFI/OC/Kexts"
    cp -r "${BUILD_DIR}/VirtualSMC/EfiDriver/VirtualSmc.efi" "${FINAL_DIR}/EFI/OC/Drivers"
    cp -r "${BUILD_DIR}/AptioFixPkg/Binaries/RELEASE/AptioMemoryFix.efi" "${FINAL_DIR}/EFI/OC/Drivers"
    cp -r "${BUILD_DIR}/OpenCoreShell/Binaries/RELEASE/Shell.efi" "${FINAL_DIR}/EFI/OC/Tools"
    cd "$BUILD_DIR/AppleSupportPkg/Binaries/RELEASE"
    rm -rf "${BUILD_DIR}/AppleSupportPkg/Binaries/RELEASE/Drivers"
    rm -rf "${BUILD_DIR}/AppleSupportPkg/Binaries/RELEASE/Tools"
    unzip *.zip >/dev/null 2>&1 || exit 1
    cp -r "${BUILD_DIR}"/AppleSupportPkg/Binaries/RELEASE/Drivers/*.efi "${FINAL_DIR}/EFI/OC/Drivers"
    cp -r "${BUILD_DIR}"/AppleSupportPkg/Binaries/RELEASE/Tools/*.efi "${FINAL_DIR}/EFI/OC/Tools"
    echo "All Done!"
}

lilucheck() {
    cd "${BUILD_DIR}/Lilu"
    repocheck
    sleep 1
}

wegcheck() {
    cd "${BUILD_DIR}/WhateverGreen"
    repocheck
    sleep 1
}

alccheck() {
    cd "${BUILD_DIR}/AppleALC"
    repocheck
    sleep 1
}

cpucheck() {
    cd "${BUILD_DIR}/CPUFriend"
    repocheck
    sleep 1
}

smccheck() {
    cd "${BUILD_DIR}/VirtualSMC"
    repocheck
    sleep 1
}

occheck() {
    cd "${BUILD_DIR}/OpenCorePkg"
    pkgcheck
    sleep 1
}

aptiocheck() {
    cd "${BUILD_DIR}/AptioFixPkg"
    pkgcheck
    sleep 1
}

supportcheck() {
    cd "${BUILD_DIR}/AppleSupportPkg"
    pkgcheck
    sleep 1
}

shellcheck() {
    cd "${BUILD_DIR}/OpenCoreShell"
    pkgcheck
    sleep 1
}

liluclone() {
    local dir[0]="${BUILD_DIR}/Lilu"
    local dir[1]="${BUILD_DIR}/WhateverGreen"
    local dir[2]="${BUILD_DIR}/AppleALC"
    local dir[3]="${BUILD_DIR}/CPUFriend"
    local dir[4]="${BUILD_DIR}/VirtualSMC"

    cd "${BUILD_DIR}/"
    echo "Cloning Lilu repo."
    git clone https://github.com/acidanthera/Lilu.git >/dev/null 2>&1 || exit 1
    cd "${BUILD_DIR}/Lilu"
    builddebug
    buildrelease
    for x in "${dir[@]}"
    do
        cp -r "${BUILD_DIR}/Lilu/build/Debug/Lilu.kext" $x
        cd $x
    done
    sleep 1
}

wegclone() {
    cd "${BUILD_DIR}/"
    echo "*****************************"
    echo "Cloning WhateverGreen repo."
    echo "*****************************"
    git clone https://github.com/acidanthera/WhateverGreen.git >/dev/null 2>&1 || exit 1
    cd "${BUILD_DIR}/WhateverGreen"
    buildrelease
    sleep 1
}

alcclone() {
    cd "${BUILD_DIR}/"
    echo "*****************************"
    echo "Cloning AppleALC repo."
    echo "*****************************"
    git clone https://github.com/acidanthera/AppleALC.git >/dev/null 2>&1 || exit 1
    cd "${BUILD_DIR}/AppleALC"
    buildrelease
    sleep 1
}

cpuclone() {
    cd "${BUILD_DIR}/"
    echo "*****************************"
    echo "Cloning CPUFriend repo."
    echo "*****************************"
    git clone https://github.com/acidanthera/CPUFriend.git >/dev/null 2>&1 || exit 1
    cd "${BUILD_DIR}/CPUFriend"
    buildrelease
    sleep 1
}

smcclone() {
    cd "${BUILD_DIR}/"
    echo "*****************************"
    echo "Cloning VirtualSMC repo."
    echo "*****************************"
    git clone https://github.com/acidanthera/VirtualSMC.git >/dev/null 2>&1 || exit 1
    cd "${BUILD_DIR}/VirtualSMC"
    buildrelease
    sleep 1
}

occlone() {
    cd "${BUILD_DIR}/"
    echo "*****************************"
    echo "Cloning OpenCore repo."
    echo "*****************************"
    git clone https://github.com/acidanthera/OpenCorePkg.git >/dev/null 2>&1 || exit 1
    cd "${BUILD_DIR}/OpenCorePkg"
    buildmactool
    sleep 1
}

aptioclone() {
    cd "${BUILD_DIR}/"
    echo "*****************************"
    echo "Cloning AptioFix repo."
    echo "*****************************"
    git clone https://github.com/acidanthera/AptioFixPkg.git >/dev/null 2>&1 || exit 1
    cd "${BUILD_DIR}/AptioFixPkg"
    buildmactool
    sleep 1
}

supportclone() {
    cd "${BUILD_DIR}/"
    echo "*****************************"
    echo "Cloning AppleSupport repo."
    echo "*****************************"
    git clone https://github.com/acidanthera/AppleSupportPkg.git >/dev/null 2>&1 || exit 1
    cd "${BUILD_DIR}/AppleSupportPkg"
    buildmactool
    sleep 1
}

shellclone() {
    cd "${BUILD_DIR}/"
    echo "*****************************"
    echo "Cloning OpenCoreShell repo."
    echo "*****************************"
    git clone https://github.com/acidanthera/OpenCoreShell.git >/dev/null 2>&1 || exit 1
    cd "${BUILD_DIR}/OpenCoreShell"
    buildmactool
    sleep 1
}

buildfoldercheck() {
    if [ ! -d "${FINAL_DIR}/" ]
    then
        echo "*******************************"
        echo "Missing ${FINAL_DIR} folder."
        echo "*******************************"
        makeDirectories
        copyBuildProducts
    else
        echo "**********************"
        echo "Updating Packages."
        echo "**********************"
        makeDirectories
        copyBuildProducts
    fi
}

echo "*********************************"
echo "Build Started"
echo "*********************************"

echo "*********************************"
echo "Beginning Build Process"
echo "*********************************"

if [ -d "${BUILD_DIR}/" ]
then
    echo "*************************************"
    echo "Acidanthera's Repos already exist."
    echo "*************************************"
if [ ! -d "${BUILD_DIR}/Lilu" ]
then
    echo "****************************"
    echo "Missing Lilu repo folder."
    echo "****************************"
    liluclone
else
    echo "*****************************************"
    echo "Lilu repo exist, checking for updates."
    echo "*****************************************"
    lilucheck
fi

if [ ! -d "${BUILD_DIR}/WhateverGreen" ]
then
    echo "*****************************************"
    echo "Missing WhateverGreen repo folder."
    echo "*****************************************"
    wegclone
else
    echo "**************************************************"
    echo "WhateverGreen repo exist, checking for updates."
    echo "**************************************************"
    cp -r "${BUILD_DIR}/Lilu/build/Debug/Lilu.kext" "${BUILD_DIR}/WhateverGreen"
    wegcheck
fi

if [ ! -d "${BUILD_DIR}/AppleALC" ]
then
    echo "********************************"
    echo "Missing AppleALC repo folder."
    echo "********************************"
    alcclone
else
    echo "*********************************************"
    echo "AppleALC repo exist, checking for updates."
    echo "*********************************************"
    cp -r "${BUILD_DIR}/Lilu/build/Debug/Lilu.kext" "${BUILD_DIR}/AppleALC"
    alccheck
fi

if [ ! -d "${BUILD_DIR}/CPUFriend" ]
then
    echo "**********************************"
    echo "Missing CPUFriend repo folder."
    echo "**********************************"
    cpuclone
else
    echo "*********************************************"
    echo "CPUFriend repo exist, checking for updates."
    echo "*********************************************"
    cp -r "${BUILD_DIR}/Lilu/build/Debug/Lilu.kext" "${BUILD_DIR}/CPUFriend"
    cpucheck
fi

if [ ! -d "${BUILD_DIR}/VirtualSMC" ]
then
    echo "**********************************"
    echo "Missing VirtualSMC repo folder."
    echo "**********************************"
    smcclone
else
    echo "**********************************************"
    echo "VirtualSMC repo exist, checking for updates."
    echo "**********************************************"
    cp -r "${BUILD_DIR}/Lilu/build/Debug/Lilu.kext" "${BUILD_DIR}/VirtualSMC"
    smccheck
fi

if [ ! -d "${BUILD_DIR}/OpenCorePkg" ]
then
    echo "***********************************"
    echo "Missing OpenCorePkg repo folder."
    echo "***********************************"
    occlone
else
    echo "***********************************************"
    echo "OpenCorePkg repo exist, checking for updates."
    echo "***********************************************"
    occheck
fi

if [ ! -d "${BUILD_DIR}/AptioFixPkg" ]
then
    echo "***********************************"
    echo "Missing AptioFixPkg repo folder."
    echo "***********************************"
    aptioclone
else
    echo "************************************************"
    echo "AptioFixPkg repo exist, checking for updates."
    echo "************************************************"
    aptiocheck
fi

if [ ! -d "${BUILD_DIR}/AppleSupportPkg" ]
then
    echo "***************************************"
    echo "Missing AppleSupportPkg repo folder."
    echo "***************************************"
    supportclone
else
    echo "****************************************************"
    echo "AppleSupportPkg repo exist, checking for updates."
    echo "****************************************************"
    supportcheck
fi

if [ ! -d "${BUILD_DIR}/OpenCoreShell" ]
then
    echo "*************************************"
    echo "Missing OpenCoreShell repo folder."
    echo "*************************************"
    shellclone
else
    echo "**************************************************"
    echo "OpenCoreShell repo exist, checking for updates."
    echo "**************************************************"
    shellcheck
fi

buildfoldercheck
else
    mkdir "${BUILD_DIR}/"
    cd "${BUILD_DIR}/"
    repoClone
    makeDirectories
    copyBuildProducts
fi

echo "*********************************"
echo "Build Process Complete Enjoy!"
echo "*********************************"

