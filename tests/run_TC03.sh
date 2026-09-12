#!/bin/bash

# Test 3: Input is not a file or it does not exist
echo "Test 3: Input is not a file or it does not exist"

output=$(bash ./assembler.sh ~)
exitCode=$?

if [[ "$output" != "usage: input is not a file or it does not exist" || "$exitCode" != 1 ]]
then
    echo "Test 3: Input is not a file or it does not exist failed"
    exit 1
fi

echo "Test 3: Input is not a file or it does not exist passed"
