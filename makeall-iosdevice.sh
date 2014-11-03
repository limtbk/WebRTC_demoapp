function fetch() {
echo "-- fetching webrtc"
gclient config --name src http://webrtc.googlecode.com/svn/trunk/
echo "target_os = ['mac']" >> .gclient
gclient sync
sed -i "" '$d' .gclient
echo "target_os = ['ios', 'mac']" >> .gclient
gclient sync
echo "-- webrtc has been sucessfully fetched"

}

function wrbase() {
export GYP_DEFINES="build_with_libjinglth_chromium=0 libjingle_objc=1"
export GYP_GENERATORS="ninja"
}

function wrios() {
wrbase
export GYP_DEFINES="$GYP_DEFINES OS=ios target_arch=armv7"
export GYP_GENERATOR_FLAGS="$GYP_GENERATOR_FLAGS output_dir=out_ios"
export GYP_CROSSCOMPILE=1
}

function buildios() {
echo "-- building webrtc ios"
pushd src
wrios
gclient runhooks
ninja -v -j 4 -C out_ios/Debug-iphoneos AppRTCDemo
popd
echo "-- webrtc has been sucessfully built"
}
 
function fail() {
echo "*** webrtc build failed"
exit 1
}
 
fetch || fail
wrios || fail
buildios || fail
