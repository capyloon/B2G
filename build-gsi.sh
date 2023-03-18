#!/bin/bash

case `uname` in
"Darwin")
        # Should also work on other BSDs
        CORE_COUNT=`sysctl -n hw.ncpu`
        ;;
"Linux")
        CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
        ;;
*)
        echo Unsupported platform: `uname`
        exit -1
esac

echo MAKE_FLAGS=-j$((CORE_COUNT + 2)) > .tmp-config

case "$1" in
"gsi_arm64_ab")
        echo PRODUCT_NAME=treble_arm64_bvN  >> .tmp-config &&
        echo TARGET_NAME=phhgsi_arm64_ab  >> .tmp-config &&
        echo DEVICE_NAME=phhgsi_arm64_ab >> .tmp-config &&
        echo BINSUFFIX=64 >> .tmp-config
        ;;
"gsi_arm_ab")
        echo PRODUCT_NAME=treble_arm_bvN  >> .tmp-config &&
        echo TARGET_NAME=phhgsi_arm_ab  >> .tmp-config &&
        echo DEVICE_NAME=phhgsi_arm_ab >> .tmp-config 
        ;;
"gsi_arm64_a")
        echo PRODUCT_NAME=treble_arm64_avN  >> .tmp-config &&
        echo TARGET_NAME=phhgsi_arm64_a  >> .tmp-config &&
        echo DEVICE_NAME=phhgsi_arm64_a >> .tmp-config &&
        echo BINSUFFIX=64 >> .tmp-config
        ;;
"gsi_arm_a")
        echo PRODUCT_NAME=treble_arm_avN  >> .tmp-config &&
        echo TARGET_NAME=phhgsi_arm_a  >> .tmp-config &&
        echo DEVICE_NAME=phhgsi_arm_a >> .tmp-config
        ;;
*)
        echo "Usage: $0 [device name] [other]"
        echo Valid devices to configure are:
        echo - gsi_arm64_ab \(arm64 partitionA/B \)
        echo - gsi_arm_ab \(arm partitionA/B \)
        echo - gsi_arm64_a \(arm64 partitionAonly \)
        echo - gsi_arm_a \(arm partitionAonly \)
        exit -1
        ;;
esac

echo GECKO_OBJDIR=$PWD/objdir-gecko-\$PRODUCT_NAME >> .tmp-config

if [ -d "./.config" ];then
  rm ./.config
fi

mv .tmp-config .config

export SKIP_ABI_CHECKS=true 

./build.sh ${@:2}
