#!/bin/sh

for i in $ARCHS; do
	if [ -f "$TEMP_FILE_DIR/archs" ]; then
		PREVIOUS_ARCHS=$(cat "$TEMP_FILE_DIR/archs")
		
		if [ "$ARCHS" != "$PREVIOUS_ARCHS" ]; then
			rm -f "$BUILT_PRODUCTS_DIR/libwired.a"
		fi
	fi
	
	if [ ! -f "$TEMP_FILE_DIR/make/$i/Makefile" ]; then
		if [ -z "$SDKROOT" ]; then
			SDKROOT=$(eval echo SDKROOT_$i); SDKROOT=$(eval echo \$$SDKROOT)
		fi
		
		if [ -z "$MACOSX_DEPLOYMENT_TARGET" ]; then
			MACOSX_DEPLOYMENT_TARGET=$(eval echo MACOSX_DEPLOYMENT_TARGET_$i); MACOSX_DEPLOYMENT_TARGET=$(eval echo \$$MACOSX_DEPLOYMENT_TARGET)
		fi
		
		RELEASE=$(uname -r)
		BUILD=$("$SRCROOT/libwired/config.guess")
		HOST="$i-apple-darwin$RELEASE"
		
		cd "$SRCROOT/libwired"
		
		if [ "$CONFIGURATION" = "Debug/Native/32" -o "$CONFIGURATION" = "Debug/Native/64" ]; then
			CFLAGS="-gdwarf-2"
		else
			CFLAGS="-gdwarf-2 -O2"
		fi
		
		if [ -d "$SRCROOT/libwired/openssl-$i" ]; then
			CPPFLAGS="-I$SRCROOT/libwired/openssl-$i/include"
			LDFLAGS="-L$SRCROOT/libwired/openssl-$i/lib"
		fi
		
		if [ "$IPHONEOS_DEPLOYMENT_TARGET" ]; then
			CFLAGS="$CFLAGS -miphoneos-version-min=$IPHONEOS_DEPLOYMENT_TARGET"
		elif [ "$MACOSX_DEPLOYMENT_TARGET" ]; then
			CFLAGS="$CFLAGS -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET"
		fi
		
		CFLAGS="$CFLAGS" CPPFLAGS="$CPPFLAGS -arch $i -I$TEMP_FILE_DIR/make/$i -isysroot $SDKROOT" LDFLAGS="$LDFLAGS" ./configure --host="$HOST" --build="$BUILD" --srcdir="$SRCROOT/libwired" --enable-warnings --enable-pthreads --enable-ssl --enable-p7 --with-objdir="$OBJECT_FILE_DIR/$i" --with-rundir="$TEMP_FILE_DIR/run/$i/libwired" || exit 1

		mkdir -p "$TEMP_FILE_DIR/make/$i" "$TEMP_FILE_DIR/run/$i" "$BUILT_PRODUCTS_DIR"
		mv "$SRCROOT/libwired/config.h" "$TEMP_FILE_DIR/make/$i/config.h"
		mv "$SRCROOT/libwired/Makefile" "$TEMP_FILE_DIR/make/$i/Makefile"
		rm -rf "$TEMP_FILE_DIR/run/$i/libwired"
		cp -r "$SRCROOT/libwired/run" "$TEMP_FILE_DIR/run/$i/libwired"
	
		if [ -d "$SRCROOT/libwired/openssl-$i" ]; then
			cp -f "$SRCROOT/libwired/openssl-$i/lib/libcrypto.a" "$BUILT_PRODUCTS_DIR/libcrypto.a"
			cp -f "$SRCROOT/libwired/openssl-$i/lib/libssl.a" "$BUILT_PRODUCTS_DIR/libssl.a"
			mkdir -p "$BUILT_PRODUCTS_DIR/openssl"
			cp -f $SRCROOT/libwired/openssl-$i/include/openssl/*.h "$BUILT_PRODUCTS_DIR/openssl/"
		fi
	fi
	
	if [ ! -d "$BUILT_PRODUCTS_DIR/wired/" ]; then
		ln -sf "$TEMP_FILE_DIR/run/$i/libwired/include/wired" "$BUILT_PRODUCTS_DIR/wired"
	fi

	cd "$TEMP_FILE_DIR/make/$i"
	make -f "$TEMP_FILE_DIR/make/$i/Makefile" || exit 1
	
	if [ "$TEMP_FILE_DIR/run/$i/libwired/lib/libwired.a" -nt "$BUILT_PRODUCTS_DIR/libwired.a" ]; then
		LIPO=1
	fi
	
	LIBWIRED_BINARIES="$TEMP_FILE_DIR/run/$i/libwired/lib/libwired.a $LIBWIRED_BINARIES"
done

echo "$ARCHS" > "$TEMP_FILE_DIR/archs"

if [ "$LIPO" ]; then
	lipo -create $LIBWIRED_BINARIES -output "$BUILT_PRODUCTS_DIR/libwired.a" || exit 1
	touch "$BUILT_PRODUCTS_DIR/libwired.a"
	ranlib "$BUILT_PRODUCTS_DIR/libwired.a"
fi

exit 0
