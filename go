cp -a ~/work/prj/6737-7.0/vendor/tinno/Fingerprint-N/native/fingerprintd/ vendor/tinno/Fingerprint-N/native/;
mmm vendor/tinno/Fingerprint-N/native/fingerprintd/;
adb root;
push out/target/product/p7201/system/bin/fingerprintd;

