#!/bin/bash

# Test 7: ADD/SUB program

echo "Test 7: ADD/SUB program"

output=$(bash ./assembler.sh tests/add.vsc)

exitCode=$?

if [[ "$exitCode" != 0 ]]
then
    echo "Test 7: ADD/SUB program failed"
    exit 1
fi

if [[ "$output" != *"It is an ADD/SUB program"* ]]
then
    echo "Test 7: ADD/SUB program failed"
    exit 1
fi

if [[ "$output" != *"The content of the .bin file is"* ]]
then
    echo "Test 7: ADD/SUB program failed"
    exit 1
fi

content=$(echo "$output" | tail -n 12)

expected="7f
0c
04
00
0c
01
08
0e
24
00
20
00"

if [[ "$content" != "$expected" ]]
then
    echo "Test 7: ADD/SUB program failed"
    exit 1
fi

echo "Test 7: ADD/SUB program passed"
