# Delete the old stuff
rm -Rf Carthage
# Make the target directories
mkdir -p Carthage/Build/iOS

cp -r ./Frameworks/iOS/fat/*.* ./Carthage/Build/iOS

zip -r MUXSDKStatsTHEOplayer.framework.zip Carthage
rm -Rf Carthage
