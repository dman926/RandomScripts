#!/bin/bash

: '
Runs a loop over files in working directory that applies mkvmerge with options.json file as default options. Useful for remuxing many video files with the same settings.
Options file needs --ui-language, --output, and input (three lines. starts and ends with parenthesis) and their options removed to run correctly
Allowed filetypes: mkv, mp4, avi. Others can be specified in $ALLOWED_FILETYPES on line 13.

-o {file}.json specifies options file. If not specified, options.json in working directory is used as options file.
-d {directory} specifies out directory. If not specified, mkvmerge_out in working directory is used as out directory.
'

declare -A ALLOWED_FILETYPES
for constant in mkv mp4 avi
do
	ALLOWED_FILETYPES[$constant]=1
done

OPTIONS="options.json"
DIRECTORY="mkvmerge_out"
ALLOW_OVERWRITE=0

while getopts "o:d:" opt; do
	case $opt in
		o)
			OPTIONS="${OPTARG}"
			;;
		d)
			DIRECTORY="${OPTARG}"
			;;
		:)
			echo "Error: -${OPTARG} requires an argument. Defaulting to default option"
			;;
		*)
			echo "Invalid flag: -{OPTARG}. Ignoring."
			;;
	esac
done

# Check $OPTIONS does not exist. Informs user and exits if true
if [[ ! -f "$OPTIONS" ]]; then
	echo "$OPTIONS does not exist. Specify with -o \{filename\} or create options.json"
	exit 1
fi

# Check if $DIRECTORY does not exist. Creates it if true. Asks user if overwrite is OK if false
if [[ ! -d "$DIRECTORY" ]]; then
	mkdir "$DIRECTORY"
elif [[ "$(ls -A "$DIRECTORY")" ]]; then
	read -r -p "$DIRECTORY is not empty. OK to overwrite in case of collisions? [Y/n] " response
	case "$response" in
		[yY][eE][sS]|[yY])
			ALLOW_OVERWRITE=1
			;;
	esac
	if [ $ALLOW_OVERWRITE == 0 ]; then
		echo "Exiting..."
		exit 0
	fi
fi

for file in *
do
	if [[ -f "$file" ]]; then
		# Check filetype is in $ALLOWED_FILETYPES
		if [[ ${ALLOWED_FILETYPES[${file##*.}]} ]]; then
			mkvmerge @"$OPTIONS"  -o "$DIRECTORY/$file" "$file"
		fi
	fi
done
