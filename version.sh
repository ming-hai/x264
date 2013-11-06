#!/bin/sh

cd "$(dirname "$0")" >/dev/null && [ -f x264.h ] || exit 1

GIT_HEAD=`git branch --list | grep "*" | awk '{print $2}'`
BUILD_ARCH=`grep "SYS_ARCH=" < config.mak | awk -F= '{print $2}'`
BIT_DEPTH=`grep "X264_BIT_DEPTH" < x264_config.h | awk '{print $3}'`
CHROMA_FORMATS=`grep "X264_CHROMA_FORMAT" < x264_config.h | awk '{print $3}'`
if [ $CHROMA_FORMATS == "0" ] ; then
    CHROMA_FORMATS="all"
elif [ $CHROMA_FORMATS == "X264_CSP_I420" ] ; then
    CHROMA_FORMATS="4:2:0"
elif [ $CHROMA_FORMATS == "X264_CSP_I422" ] ; then
    CHROMA_FORMATS="4:2:2"
elif [ $CHROMA_FORMATS == "X264_CSP_I444" ] ; then
    CHROMA_FORMATS="4:4:4"
fi

api="$(grep '#define X264_BUILD' < x264.h | sed 's/^.* \([1-9][0-9]*\).*$/\1/')"
ver="x [${BIT_DEPTH}-bit@${CHROMA_FORMATS} ${BUILD_ARCH}]"
version=""

if [ -d .git ] && command -v git >/dev/null 2>&1 ; then
    localver="$(($(git rev-list HEAD | wc -l)))"
    if [ "$localver" -gt 1 ] ; then
        ver_diff="$(($(git rev-list origin/plain..HEAD | wc -l)))"
        ver="$((localver-ver_diff))"
        echo "#define X264_REV $ver"
        echo "#define X264_REV_DIFF $ver_diff"
        if [ "$ver_diff" -ne 0 ] ; then
            ver="$ver+$ver_diff"
        fi
        if git status | grep -q "modified:" ; then
            ver="${ver}M"
        fi
        ver="$ver $(git rev-list -n 1 HEAD | cut -c 1-7) $GIT_HEAD [${BIT_DEPTH}-bit@${CHROMA_FORMATS} ${BUILD_ARCH}]"
        version=" r$ver"
    fi
fi

echo "#define X264_VERSION \"$version\""
echo "#define X264_POINTVER \"0.$api.$ver\""
