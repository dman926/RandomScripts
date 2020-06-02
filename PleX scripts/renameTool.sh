#!/bin/bash

: '
Renames all files in a given folder
$1 is the new file name without episode numbers. Ex: "TV Show S01E"
$2 is the file extension
'

count=0
for file in *
	do
		((count++))
		printf -v padded "%02d" $count
		outFile="${1}${padded}${2}"
		mv "$file" "$outFile"
	done
