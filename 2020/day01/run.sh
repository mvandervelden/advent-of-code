#!/bin/sh
TMPFILE=`mktemp /tmp/Project.swift.XXXXXX` || exit 1
trap "rm -f $TMPFILE" EXIT
cat *.swift ../Shared/*.swift > $TMPFILE
swift $TMPFILE $@
