#!/bin/bash
set -e

APK_FILE=$1
OUTPUT_APK=$2
SDK_TARGET=${3-23}

if [ -z "$APK_FILE" ] || [ -z "$OUTPUT_APK" ] || [-z "$SDK_TARGET" ]; then
	echo "Usage: $0 input.apk output.apk target_sdk_version(default=23)"
    exit 1
fi

# Decompile APK
apktool d "$APK_FILE" -o decompiled_apk

# Modify AndroidManifest.xml
#sed -i 's/android:minSdkVersion="[0-9]*"/android:minSdkVersion="23"/' decompiled_apk/AndroidManifest.xml
sed -i s/"minSdkVersion: '[0-9]*'"/"minSdkVersion: '$SDK_TARGET'"/ decompiled_apk/apktool.yml

# Rebuild APK
apktool b decompiled_apk -o rebuilt.apk

# Align the APK
zipalign -v 4 rebuilt.apk aligned.apk

# Generate keystore.jks

keytool -genkey -v -keystore /tmp/keystore.jks -alias mykey \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=test, OU=test, O=test, L=test, S=test, C=test" \
    -storepass password -keypass password


# Sign the APK
echo password | apksigner sign --ks /tmp/keystore.jks --v1-signing-enabled true --v2-signing-enabled true \
	--out "$OUTPUT_APK" aligned.apk

# Clean up
rm -rf decompiled_apk rebuilt.apk aligned.apk $OUTPUT_APK.idsig

echo "Modified APK created: $OUTPUT_APK"


