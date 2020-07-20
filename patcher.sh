#!/bin/bash
#regex [0-9]+\.[0-9]+(\.[1-9][0-9]?)?

patched=no
path=kernel_to_patch/drivers/tty/serial/8250
exit_='false'
clean='false'
help='false'
forced_kernel=''
kernel=''
majorv=''
url=''

helpmenu () { help='true'; }

clean () { clean='true'; }

force-kernel () { forced_kernel=$1; }

while [ ! $# -eq 0 ]
do
	case "$1" in
        --kernel | -k)
            shift
            force-kernel $1
            ;;
		--clean | -c)
			clean
			;;
        --help | -h)
			helpmenu
			;;
	esac
	shift
done

if [[ -z "${forced_kernel}" ]] 
then
    kernel=$((uname -r) | grep -o -E [0-9]+\\.[0-9]+\(\\.[1-9][0-9]?\)? | cut -f1 -d$'\n')
    echo "Using detected kernel version $kernel"
else
    echo "Using forced kernel $forced_kernel"
    kernel=$forced_kernel
fi

majorv=$(echo $kernel | grep -o -E ^[0-9])
url=https://mirrors.edge.kernel.org/pub/linux/kernel/v$majorv.x/linux-$kernel.tar.gz

if [[ $clean == 'true' ]]
then
    printf "*** Cleaning ***\n"
    if [ -f linux-$kernel.tar.gz ]; then
       printf "Deleting linux-$kernel.tar.gz\n"
       rm linux-$kernel.tar.gz
    else
       printf "linux-$kernel.tar.gz does not exist. Skipping...\n"

    fi

    if [ -d linux-$kernel ]; then
        printf "Deleting linux-$kernel\n"
        rm -rf linux-$kernel
    else
    printf "linux-$kernel does not exist. Skipping...\n"
        
    fi

    if [ -d "kernel_to_patch/drivers" ]; then
        printf "Deleting kernel_to_patch/drivers\n"
        rm -rf kernel_to_patch/drivers
    else
        printf "kernel_to_patch/drivers does not exist. Skipping...\n"
        
    fi
    if [ -f 8250_exar.ko ]; then
        printf "Deleting 8250_exar.ko\n"
        rm 8250_exar.ko
    
    else
       printf "8250_exar.ko does not exist. Skipping...\n"
    fi

    printf "Clean complete\n"

    exit_='true'
fi

if [[ $help == 'true' ]]; then

    echo Usage: ./patcher [OPTIONS]
    echo OPTIONS:
    echo "--clean, -c   : Resets to starting state. Deletes downloaded kernel, extracted files, and contents of kernel_to_patch"    
    echo "--kernel, -k  : Forces a certain kernel version to be used. Format as x.x.x please. For example, ./script -k 4.15.2"
    echo "--help, -h    : Displays this help"
    exit_='true'
fi

if [[ $exit_ == 'true' ]]; then
    printf "Exiting...\n"
    exit 0
fi

printf "Do you want to download and extract kernel source for $kernel from $url?\n(Enter [y]es or [n]o)\n"
read download

if [[ $download == yes ]] || [[ $download == y ]]
then

    if [ ! -f linux-$kernel.tar.gz ]; then
        printf "Downloading kernel version $kernel\n"
        wget $url
    else
        printf "Already downloaded. Skipping...\n"
    fi

    if [ ! -d linux-$kernel ]; then
        printf "Extracting linux-$kernel.tar.gz\n"
        tar -zxf linux-$kernel.tar.gz
    else
        printf "Already extracted linux-$kernel.tar.gz. Skipping...\n"
    fi

    printf "Copying linux-$kernel/drivers to kernel_to_patch/drivers\n"
       
    if [ ! -f linux-$kernel.tar.gz ]; then
        mkdir linux-$kernel/drivers
    fi

    rsync --recursive --info=progress2 linux-$kernel/drivers kernel_to_patch
    
elif [[ $download == no ]] || [[ $download == n ]]
then
    if [ ! -f "kernel_to_patch/drivers/tty/serial/8250/8250_exar.c" ]; then
        printf "[ERROR] kernel_to_patch/drivers/tty/serial/8250/8250_exar.c not found! Make sure you have copied the driver folder correctly. \nExiting...\n"
        exit 0
    fi
fi

echo ""

if [[ ($kernel =~ [4]+\.[1][1] || $kernel =~ [4]+\.[1][2]) ]]  #kernel version is 4.11.x or 4.12.x
then
    echo "*** Applying 4.11-4.12 patch ***"
    echo ""
    patch -u $path/8250_exar.c -i 8250_exar_4.11-4.12.patch
    patched=yes
    echo ""

else
    echo "*** Applying 4.13+ patch ***"
    echo ""
    patch -u $path/8250_exar.c -i 8250_exar_4.13+.patch
    patched=yes
    echo ""
fi

if [[ $patched == yes ]]
then
    echo "*** Applying makefile patch ***"
    echo ""
    patch -u $path/Makefile -i Makefile.patch -R

    echo ""

    echo "*** Building kernel module ***"
    echo ""
    (cd $path && make)

    echo ""

    if [ -f $path/8250_exar.ko ]; then

        echo "*** Copied compiled module (8250_exar.ko) to this directory for easy access ***"
        echo ""
        cp $path/8250_exar.ko 8250_exar.ko
    else
        echo "*** ERROR: Failed to compile 8250_exar driver***"
        echo "Suggested fix: Please make sure kernel_to_patch/drivers/tty/serial/8250/8250_exar.c is present"
        echo "Suggested fix: Please make sure you have the build tools required for your system"
        echo ""
        echo "Consult with your company, distribution, and/or package documentation before installing"
        echo "Suggested packages for CentOS (https://wiki.centos.org/HowTos/Custom_Kernel)"
        echo "    * yum groupinstall 'Development Tools'"
        echo "    * yum install ncurses-devel"
        echo "    * yum install hmaccalc zlib-devel binutils-devel elfutils-libelf-devel"
        echo "Suggested packages for Ubuntu (https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel)"
        echo "    * sudo apt-get build-dep linux linux-image-$(uname -r)"
        echo "    * sudo apt-get install libncurses-dev flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf"
    fi
else
    echo "Patch failed! Unable to identify patch version. Try using --force-kernel {x.x.x} option"
    echo ''
fi
