#!/bin/bash

src=`find . -name '*.cs'`

csc $src

if [ "$?" != "0" ]; then
    echo "csc failed"
    exit 1
fi

./main.exe
