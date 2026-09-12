#!/bin/bash

#Test 1: No Argument
echo "Test1: No Argument"

output=$(bash ../assembler.sh)
exitCode=$?

if [[ "$output" != "usage: no argument is provided" || "$exitCode" != 1 ]]
then
	echo "Test 1: No Argument failed"
	exit 1
fi
echo "Test 1: No Argument passed"
