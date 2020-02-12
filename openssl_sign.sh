#!/bin/bash

hash_file="$1"
key_path=/home/android/driver/k150-9.0/vendor/sprd/proprietories-source/packimage_scripts/signimage/sprd/config/rsa4096_product.pem

inData=/home/android/tmp/k150/data.txt
outData=/home/android/tmp/k150/sig.bin
# openssl "rsautl -sign -inkey $key_path -raw $digest"
openssl rsautl -sign -in $inData -out $outData -inkey $key_path

echo "done."



