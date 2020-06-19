#!/usr/bin/env bash

# Config
NAME="Win10"
URL="https://az792536.vo.msecnd.net/vms/VMBuild_20190311/VirtualBox/MSEdge/MSEdge.Win10.VirtualBox.zip"
RAM="8G"
SNAPSHOT_MODE=1			# Snapshot mode by default


VMNAME="$NAME.qcow2"

get_image() {
    # Retreive file
    wget -O Win10.zip -c -nv --show-progress $URL	
    # Extract ova
    ova_file=`unzip -l -qq Win10.zip | sed 's/[^ ]* [^ ]* [^ ]* [^ ]* *\(.*\)$/\1/g'`
    unzip -n Win10.zip
    # Extract vmdk
    vmdk_file=`tar tf "$ova_file" | grep vmdk$`
    if ! [ -f "$vmdk_file" ]; then
	tar xvf "$ova_file" "$vmdk_file" --checkpoint=.1000
    fi
    qemu-img convert -O qcow2 "$vmdk_file" "$VMNAME"
}

run() {
    echo hi
}

for arg in "$@"; do
    case $arg in
	-p|--persistent)
	    SNAPSHOT_MODE=0
	    ;;
    esac
    
done

if ! [ -f $VMNAME ]; then
    get_image
    SNAPSHOT_MODE=0		# Running for the first time
fi

# Run the VM
if [ $SNAPSHOT_MODE ]; then
    qemu-kvm -m "$RAM" -daemonize "$VMNAME"
else
    qemu-kvm -m "$RAM" -snapshot -daemonize "$VMNAME"
fi


