#!/bin/bash

# Test 5: Empty file
echo "Test 5: Empty file"

output=$(bash ./assembler.sh tests/empty.vsc)
exitCode=$?

if [[ "$output" != "usage: the file is empty - no .bin file is produced" || "$exitCode" != 1 ]]
then
    echo "Test 5: Empty file failed"
    exit 1
fi

echo "Test 5: Empty file passed"
