#!/bin/bash

set -e

LINUX_BIN=bluejay_dist/bluejay/linux-x86/bin

rm -rf bluejay_dist
mkdir -p bluejay_dist/bluejay/images
mkdir -p ${LINUX_BIN}

cp out/target/product/bluejay/*.img bluejay_dist/bluejay/images
cp out/target/product/bluejay/android-info.txt bluejay_dist/bluejay/images
cp out/host/linux-x86/bin/fastboot ${LINUX_BIN}
cp out/host/linux-x86/bin/adb ${LINUX_BIN}

cat << EOF > bluejay_dist/bluejay/flash.sh
#!/bin/sh

# Copyright 2012 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


set -e

IMG=./images

HOST_OS=\$(uname -s)
if [ "\$HOST_OS" != "Darwin" ]; then
    PATH=./linux-x86/bin:\$PATH
fi

# Make sure we use an up to date version of fastboot.
# Copied from the factory install 'flash-all.sh' script.
if ! [ \$(\$(which fastboot) --version | grep "version" | cut -c18-23 | sed 's/\.//g' ) -ge 3301 ]; then
  echo "fastboot too old; please download the latest version at https://developer.android.com/studio/releases/platform-tools.html"
  exit 1
fi

export ANDROID_PRODUCT_OUT=\$IMG

adb reboot bootloader

fastboot flashall -w

fastboot reboot
EOF

chmod +x bluejay_dist/bluejay/flash.sh

# cp $ANDROID_PRODUCT_OUT/obj/DATA/sources.xml_intermediates/sources.xml ./bluejay_dist/bluejay/

cd bluejay_dist; tar cf - bluejay | xz -v --threads=0 > bluejay.tar.xz

echo "==> bluejay_dist/bluejay.tar.xz is ready!"
