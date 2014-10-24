WebRTC_demoapp
==============

HOWTO build libs

Links used:
http://ninjanetic.com/how-to-get-started-with-webrtc-and-ios-without-wasting-10-hours-of-your-life/
http://www.webrtc.org/reference/getting-started

0) create work directory

1) get depot tools and add them to PATH

git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

2) copy to work directory and run makeall-iossim.sh for build and run on simulator, and makeall-iosdevice.sh for phone. Fetch will take a lot of time. After build copy .a files from /src/out_sim/Debug or /src/out_ios/Debug-iphoneos to libs directory in WebRTCTest.
