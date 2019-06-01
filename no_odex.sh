#!/bin/bash

for f in `find device/tinno/ -name BoardConfig.mk`
do
    echo change ${f}
    echo "WITH_DEXPREOPT := false" >> ${f}
done


exit 0;


echo "1"
