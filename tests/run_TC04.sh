#!/bin/bash

# Test 4: Invalid file extension
echo "Test 4: Invalid file extension"

output=$(bash ./assembler.sh tests/no_vsc.vs)
exitCode=$?

if [[ "$output" != "usage: input does not have the extension .vsc" || "$exitCode" != 1 ]]
then
    echo "Test 4: Invalid file extension failed"
    exit 1
fi

echo "Test 4: Invalid file extension passed"
