#!/bin/bash

find ./ -type f  \( -name '*.exe' -o -name '*.tmp' -o -name '*.pif' -o -name '*.inf' -o -name '*.lnk' \) > ~/.file
sed -i 's/^/\"/' ~/.file
sed -i 's/$/\"/' ~/.file
cat ~/.file |xargs rm -f -v
rm ~/.file

exit 0;

