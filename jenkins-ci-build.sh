#!/bin/bash

UNAME=`uname`
MASTER_DIR=`dirname $0`
BUILD_DEFAULT="release"

cd ${MASTER_DIR}

if [ "$OPTIONS" = "all_options" ];
then
	export USE_CODEC_VORBIS=1
	export USE_FREETYPE=1
fi

if [ "$UNAME" == "Darwin" ]; then
	CORES=`sysctl -n hw.ncpu`
elif [ "$UNAME" == "Linux" ]; then
	CORES=`awk '/^processor/ { N++} END { print N }' /proc/cpuinfo`
fi

echo "platform      : ${UNAME}"
echo "cores         : ${CORES}"
if [ "${BUILD_TYPE}" == "" ]; then
	BUILD_TYPE="${BUILD_DEFAULT}"
	echo "build type    : defaulting to ${BUILD_TYPE}"
else
	echo "build type    : ${BUILD_TYPE}"
fi

if [ -n "${CPPCHECK}" ]; then
	if [ -e "${CPPCHECK}" ]; then
		# Copy the existing output
		BASENAME_CPPCHECK=`basename ${CPPCHECK}`
		cp ${CPPCHECK} ./${BASENAME_CPPCHECK}
	else
		CHECK_CPPCHECK=`command -v cppcheck >/dev/null`
		if [ "$?" != "0" ]; then
			echo "cppcheck not installed"
			exit 1
		fi

		cppcheck --enable=all --max-configs=1 --xml --xml-version=2 ./code 2> ${CPPCHECK}
	fi
fi

make -j${CORES} distclean ${BUILD_TYPE}

exit $?
