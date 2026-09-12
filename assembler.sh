#!/bin/bash
#check the validation of the argument
if [ $# -eq 0 ]
then
    echo "usage: no argument is provided"
    exit 1
fi
if [ $# -gt 1 ]
then
    echo "usage: more than one arguments are provided"
    exit 1
fi
#check if the file exists
if [ ! -f "$1" ]
then
    echo "usage: input is not a file or it does not exist"
    exit 1
fi
#check if the file ends with .vsc
if [[ "$1" != *.vsc ]]
then
    echo "usage: input does not have the extension .vsc"
    exit 1
fi
#check if the input file is empty
if [ ! -s "$1" ]
then
    echo "usage: the file is empty - no .bin file is produced"
    exit 1
fi
#Function: convert the decimal to binary
decimalToBinary(){
    local number="$1"
    local binary=""
    for((i=7; i>=0; i--))
    do
        local power=$((2**i))
        if [[ "$number" -ge "$power" ]]
        then
            binary+="1"
            number=$((number - power))
        else
            binary+="0"
        fi
    done
    echo "$binary"
}
#Function: convert the decimal to binary
binaryToDecimal(){
    local binary="$1"
    local decimal=0

    for((i=0; i<8; i++))
    do
        local bit="${binary:i:1}"
        decimal=$((decimal * 2 + bit))
    done

    echo "$decimal"
}
#get the .bin filename
outputFile="${1%.vsc}.bin"
#read the .vsc file and get the first line
n_values=$(head -n 1 "$1")
if [[ "$n_values" != 0 && "$n_values" != 2 ]]
then
    echo "Error: the first line must be 0 or 2"
    exit 1
fi
#check if the second line is 'QUIT,0,0' when n_values is 0
if [[ "$n_values" == 0 ]]
then
    secondLine=$(head -n 2 "$1"| tail -n 1)
    if [[ "$secondLine" != "QUIT,0,0" ]]
    then
        echo "Error: when n_values is 0, the next line must be QUIT,0,0"
        exit 1
    fi
    #write the file in hexadecimal - opcode+register & memory = 2 byte
    printf '\x20' > "$outputFile"
    printf '\x00' >> "$outputFile"
    echo "It is a QUIT program"
    echo "The content of the .bin file is"
    xxd -p -c 1 "$outputFile"
    exit 0
fi
#get the second line and the third line and check them
if [ "$n_values" == 2 ]
then
    value1=$(head -n 2 "$1" | tail -n 1)
    value2=$(head -n 3 "$1" | tail -n 1)
    if [[ ! "$value1" =~ ^[0-9]+$ ]]
    then
        echo "Line 2 is not an integer"
        exit 1
    fi
    if [[ ! "$value2" =~ ^[0-9]+$ ]]
    then
        echo "Line 3 is not an integer"
        exit 1
    fi
    if [[ "$value1" -lt 0 || "$value1" -ge 128 ]]
    then
        echo "Line 2 is not in [0,128)"
        exit 1
    fi
    if [[ "$value2" -lt 0 || "$value2" -ge 128 ]]
    then
        echo "Line 3 is not in [0,128)"
        exit 1
    fi
    dataArray=()
    hexValue1=$(printf '%02x' "$value1")
    hexValue2=$(printf '%02x' "$value2")

    dataArray+=("$hexValue1")
    dataArray+=("$hexValue2")
    lineNumber=0
    while read line
    do
        ((lineNumber++))
        #skip first 3 lines
        if [ "$lineNumber" -le 3 ]
        then
            continue
        fi
        #check the length of the instruction
        if [ "${#line}" -gt 11 ]
        then
            echo "Error: the instruction is too long"
            exit 1
        fi
        #split each line by ',' and store each part
        IFS=',' read -r instruction register address <<< "$line"
        if [ "$lineNumber" -gt 103 ]
        then
            echo "Error: too many instructions"
            exit 1
        fi
        #check the instruction and get the opcode
        if [ "$instruction" == "LOAD" ]
        then
            opcode="000001"
        elif [ "$instruction" == "STORE" ]
        then
            opcode="000010"
        elif [ "$instruction" == "ADD" ]
        then
            opcode="000011"
        elif [ "$instruction" == "SUB" ]
        then
            opcode="000100"
        elif [ "$instruction" == "QUIT" ]
        then
            opcode="001000"
        elif [ "$instruction" == "PRINT" ]
        then
            opcode="001001"
        else
            echo "Error: invalid instruction"
            exit 1
        fi
        #check the register
        if [[ ! "$register" =~ ^[0-9]+$ ]]
        then
            echo "Error: register is not an integer"
            exit 1
        fi
        if [[ "$register" -lt 0 || "$register" -ge 4 ]]
        then
            echo "Error: register is not in [0,4)"
            exit 1
        fi
        #check the memory address
        if [[ ! "$address" =~ ^[0-9]+$ ]]
        then
            echo "Error: address is not an integer"
            exit 1
        fi
        if [[ "$address" -lt 0 || "$address" -ge 256 ]]
        then
            echo "Error: address is not in [0,256)"
            exit 1
        fi
        #convert the register to binary and save the last 2 bits
        registerBinary=$(decimalToBinary "$register")
        registerBinary="${registerBinary:6:2}"
        firstByteBinary="${opcode}${registerBinary}"
        secondByteBinary=$(decimalToBinary "$address")

        decimal1=$(binaryToDecimal "$firstByteBinary")
        decimal2=$(binaryToDecimal "$secondByteBinary")

        hex1=$(printf '%02x' "$decimal1")
        hex2=$(printf '%02x' "$decimal2")


        dataArray+=("$hex1")
        dataArray+=("$hex2")
        if [[ "$instruction" == "QUIT" && "$register" == "0" && "$address" == "0" ]]
        then
            break
        fi
    done < "$1"
    #initialize the file and write the bytes in the dataArray
    > "$outputFile"
    for byte in "${dataArray[@]}"
    do
        printf '%b' "\\x$byte" >> "$outputFile"
    done
fi
echo "It is an ADD/SUB program"
echo "The content of the .bin file is"
#display the outputFile in a readable way without address, 1 byte each line
xxd -p -c 1 "$outputFile"
