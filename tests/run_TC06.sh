#!/bin/bash

#Test 6: QUIT program
echo "Test 6: QUIT program"

output=$(bash ./assembler.sh tests/quit.vsc)
exitCode=$?

if [[ "$exitCode" != 0 ]]
then
	echo "Test 6 QUIT program failed"
	exit 1
fi

if [[ "$output" != "It is a QUIT program"* ]]
then
	echo "Test 6: QUIT program failed"
	exit 1
fi

if [[ "$output" != *"The content of the .bin file is"* ]]
then
	echo "Test 6: QUIT program failed"
	exit 1
fi

if [[ "$output" != *"20"* || "$output" != *"00"* ]]
then
	echo "Test 6: QUIT program failed"
	exit 1
fi

echo "Test 6: QUIT program passed"

