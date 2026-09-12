#!/bin/bash

# Test 2: More than one Argument
echo "Test 2: More than one Argument"

output=$(bash ./assembler.sh a.vsc b.vsc)
exitCode=$?

if [[ "$output" != "usage: more than one arguments are provided" || "$exitCode" != 1 ]]
then
    echo "Test 2: More than one Argument failed"
    exit 1
fi

echo "Test 2: More than one Argument passed"
