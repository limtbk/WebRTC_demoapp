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
export GYP_DEFINES="build_with_libjingle=1 build_with_chromium=0 libjingle_objc=1"
export GYP_GENERATORS="ninja"
}

function wrsim() {
wrbase
export GYP_DEFINES="$GYP_DEFINES OS=ios target_arch=ia32"
export GYP_GENERATOR_FLAGS="$GYP_GENERATOR_FLAGS output_dir=out_sim"
export GYP_CROSSCOMPILE=1
}

function build() {
echo "-- building webrtc"
pushd src
gclient runhooks
ninja -v -j 4 -C out_sim/Debug iossim AppRTCDemo
popd
echo "-- webrtc has been sucessfully built"
}

function fail() {
echo "*** webrtc build failed"
exit 1
}

fetch || fail
wrsim || fail
build || fail
