#!/bin/sh

cd `dirname $0`

agvtool bump

MARKETING_VERSION=`agvtool what-marketing-version -terse | grep OpenVBX | sed "s/[^=]*=//"`
BUILD_NUMBER=`agvtool what-version -terse`
REV=`svnversion -n`

VERSION_STRING="$MARKETING_VERSION.$BUILD_NUMBER.$REV"

echo "Version: $VERSION_STRING"
