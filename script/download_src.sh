#!/bin/sh
sudo apt-get update
sudo apt-get install -y aptitude ccache

# libncurses5
sudo aptitude install -y libncurses5-dev

# openjdk8
sudo apt-get install -y openjdk-8-jdk
JAVA_8_HOME=$(readlink -f /usr/lib/jvm/java-8-openjdk-amd64)
echo "JAVA_HOME=${JAVA_8_HOME}" >>$GITHUB_ENV
echo "${JAVA_8_HOME}/bin" >>$GITHUB_PATH
sudo update-alternatives --set java "${JAVA_8_HOME}/bin/java"
sudo update-alternatives --set javac "${JAVA_8_HOME}/bin/javac"

git clone --depth 1 "https://github.com/kiwibrowser/src" src
cd "$ROOT/src"
curl "https://omahaproxy.appspot.com/all" | grep -Fi "android,stable" | cut -f3 -d"," | awk '{split($0,a,"."); print "MAJOR=" a[1] "\nMINOR=" a[2] "\nBUILD=" a[3] "\nPATCH=" a[4]}' >chrome/VERSION
sudo bash install-build-deps.sh --no-chromeos-fonts
build/linux/sysroot_scripts/install-sysroot.py --arch=i386
build/linux/sysroot_scripts/install-sysroot.py --arch=amd64
keytool -genkey -v -keystore keystore.jks -alias dev -keyalg RSA -keysize 2048 -validity 10000 -storepass public_password -keypass public_password -dname "cn=Kiwi Browser (unverified), ou=Actions, o=Kiwi Browser, c=GitHub"
gclient runhooks
