#!/bin/zsh
# Builds Harness.app for the iOS simulator, with the library sources compiled in.
set -e
H=$(dirname $0:A); LIB=$H/../SkeletonViewCore/Sources
SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
ARCH=$(uname -m)
rm -rf $H/build; mkdir -p $H/build/Harness.app
xcrun swiftc -sdk $SDK -target $ARCH-apple-ios15.0-simulator -module-name Harness -swift-version 5 -Onone -suppress-warnings \
  -o $H/build/Harness.app/Harness $H/main.swift $(find $LIB -name '*.swift')
cat > $H/build/Harness.app/Info.plist <<P
<?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>com.skeletonview.harness</string>
<key>CFBundleExecutable</key><string>Harness</string>
<key>CFBundleName</key><string>Harness</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1</string>
<key>UILaunchScreen</key><dict/>
<key>UIApplicationSceneManifest</key><dict>
  <key>UIApplicationSupportsMultipleScenes</key><false/>
  <key>UISceneConfigurations</key><dict><key>UIWindowSceneSessionRoleApplication</key><array><dict>
    <key>UISceneConfigurationName</key><string>Default</string>
    <key>UISceneDelegateClassName</key><string>Harness.SceneDelegate</string>
  </dict></array></dict>
</dict>
</dict></plist>
P
