# Delete the old stuff
rm -Rf Frameworks
# Make the target directories
mkdir -p Frameworks/iOS/fat
mkdir -p Frameworks/iOS/release
mkdir -p Frameworks/iOS/simulator

cd MUXSDKStatsTHEOplayer

# Build iOS release SDK
xcodebuild -workspace 'MUXSDKStatsTHEOplayer.xcworkspace' -configuration Release archive -scheme 'MUXSDKStatsTHEOplayer' SYMROOT=$PWD/ios
# Build iOS simulator SDK
xcodebuild -workspace 'MUXSDKStatsTHEOplayer.xcworkspace' -configuration Release -scheme 'MUXSDKStatsTHEOplayer' -destination 'platform=iOS Simulator,name=iPhone 7' SYMROOT=$PWD/ios

# Prepare the release .framework
cp -R -L ios/Release-iphoneos/MUXSDKStatsTHEOplayer.framework ios/MUXSDKStatsTHEOplayer.framework
cp -R ios/Release-iphoneos/MUXSDKStatsTHEOplayer.framework.dSYM ios/MUXSDKStatsTHEOplayer.framework.dSYM
TARGET_IOS_BINARY=$PWD/ios/MUXSDKStatsTHEOplayer.framework/MUXSDKStatsTHEOplayer
rm $TARGET_IOS_BINARY

# Make the iOS fat binary
lipo -create ios/Release-iphoneos/MUXSDKStatsTHEOplayer.framework/MUXSDKStatsTHEOplayer ios/Release-iphonesimulator/MUXSDKStatsTHEOplayer.framework/MUXSDKStatsTHEOplayer -output $TARGET_IOS_BINARY
/usr/libexec/PlistBuddy -c 'Add :CFBundleSupportedPlatforms:1 string iPhoneSimulator' $PWD/ios/MUXSDKStatsTHEOplayer.framework/Info.plist
cp -R ios/Release-iphonesimulator/MUXSDKStatsTHEOplayer.framework/Modules/MUXSDKStatsTHEOplayer.swiftmodule/* $PWD/ios/MUXSDKStatsTHEOplayer.framework/Modules/MUXSDKStatsTHEOplayer.swiftmodule

cd ..

# Copy over iOS frameworks
cp -R MUXSDKStatsTHEOplayer/ios/Release-iphonesimulator/MUXSDKStatsTHEOplayer.framework Frameworks/iOS/simulator/MUXSDKStatsTHEOplayer.framework
cp -R MUXSDKStatsTHEOplayer/ios/Release-iphonesimulator/MUXSDKStatsTHEOplayer.framework.dSYM Frameworks/iOS/simulator/MUXSDKStatsTHEOplayer.framework.dSYM
cp -R -L MUXSDKStatsTHEOplayer/ios/Release-iphoneos/MUXSDKStatsTHEOplayer.framework Frameworks/iOS/release/MUXSDKStatsTHEOplayer.framework
cp -R MUXSDKStatsTHEOplayer/ios/Release-iphoneos/MUXSDKStatsTHEOplayer.framework.dSYM Frameworks/iOS/release/MUXSDKStatsTHEOplayer.framework.dSYM
cp -R MUXSDKStatsTHEOplayer/ios/MUXSDKStatsTHEOplayer.framework Frameworks/iOS/fat/MUXSDKStatsTHEOplayer.framework
cp -R MUXSDKStatsTHEOplayer/ios/MUXSDKStatsTHEOplayer.framework.dSYM Frameworks/iOS/fat/MUXSDKStatsTHEOplayer.framework.dSYM


# Clean up
rm -Rf MUXSDKStatsTHEOplayer/ios
