#!/bin/bash

OUTPUT_SIMULATOR="./src/out_sim/Debug"
OUTPUT_ARMV7="./src/out_ios/Debug-iphoneos"

OUTPUT_UNIVERSAL="./universallib"

mkdir -p $OUTPUT_UNIVERSAL

for f in $OUTPUT_SIMULATOR/*.a
do
    n=`basename $f .a`
    if [ ! -f $OUTPUT_ARMV7/$n.a ]; then
	echo "File $n not found for armv7"
	cp "$OUTPUT_SIMULATOR/$n.a" "$OUTPUT_UNIVERSAL/$n.a"
    else
	lipo -create "$OUTPUT_SIMULATOR/$n.a" "$OUTPUT_ARMV7/$n.a" -output "$OUTPUT_UNIVERSAL/$n.a"
    fi
done

for f in $OUTPUT_ARMV7/*.a
do
    n=`basename $f .a`
    if [ ! -f $OUTPUT_SIMULATOR/$n.a ]; then
	echo "File $n not found for i386"
	cp "$OUTPUT_ARMV7/$n.a" "$OUTPUT_UNIVERSAL/$n.a"
    fi
done
