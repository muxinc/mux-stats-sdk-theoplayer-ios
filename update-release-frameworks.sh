BUILD_DIR=$PWD/MUXSDKStatsTHEOplayer/xc
PROJECT=$PWD/MUXSDKStatsTHEOplayer/MUXSDKStatsTHEOplayer.xcworkspace
TARGET_DIR=$PWD/XCFramework


# Delete the old stuff
rm -Rf $TARGET_DIR

# Make the build directory
mkdir -p $BUILD_DIR
# Make the target directory
mkdir -p $TARGET_DIR

# Clean up on error
clean_up_error () {
    rm -Rf $BUILD_DIR
    exit 1
}

# Build and clean up on error
build () {
  scheme=$1
  destination="$2"
  path="$3"
  
  xcodebuild archive -scheme $scheme -workspace $PROJECT -destination "$destination" -archivePath "$path" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES || clean_up_error
}

################ Build MUXSDKStatsTHEOplayer SDK
#
build MUXSDKStatsTHEOplayer "generic/platform=iOS" "$BUILD_DIR/MUXSDKStatsTHEOplayer.iOS.xcarchive"
build MUXSDKStatsTHEOplayer "generic/platform=iOS Simulator" "$BUILD_DIR/MUXSDKStatsTHEOplayer.iOS-simulator.xcarchive"
  
 xcodebuild -create-xcframework -framework "$BUILD_DIR/MUXSDKStatsTHEOplayer.iOS.xcarchive/Products/Library/Frameworks/MUXSDKStatsTHEOplayer.framework" \
                                -framework "$BUILD_DIR/MUXSDKStatsTHEOplayer.iOS-simulator.xcarchive/Products/Library/Frameworks/MUXSDKStatsTHEOplayer.framework" \
                                -output "$TARGET_DIR/MUXSDKStatsTHEOplayer.xcframework" || clean_up_error

# Clean up
rm -Rf $BUILD_DIR
