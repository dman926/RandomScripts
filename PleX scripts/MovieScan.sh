#!/bin/bash

: '
Prints movie name, total size, and average size/minute
Should only be ru in directories for Plex movies
Does not enter subdirectories

It is recommended to pipe to the more command for readability, as this script produces a lot of output. Example usage ./MovieScan | more
'

# Total size warnings
warnSize=2000000000
alertSize=2500000000
warnTextSize="2GB"
alertTextSize="2.5GB"

# Size/minute warnings
warnMinSize=$(($warnSize / 7200))
alertMinSize=$(($alertSize / 7200))
warnMinTextSize="0.28MB"
alertMinTextSize="0.35MB"

breakdown () { # title, size, length
	echo "Movie: $1"
	paddedSize=$(printf %9s $2) # Pad total size to display in gigabytes
	echo "Total Size: ${paddedSize:0:-9}.${paddedSize: -9} GB"
	printf 'Run Time: %02dH:%02dM:%02dS\n' $(($3/3600)) $(($3%3600/60)) $(($3%60))
	tmpSize=$(($2 / $(($3 / 60)))) # Calculate size/minute
	sizepmin=$(printf %6s $tmpSize) # Pad size/minute to display in megabytes
	echo "Size/Minute: ${sizepmin:0:-9}.${sizepmin: -9} GB"
	if [ $2 -ge $alertSize ]
	then
		echo -e "\033[1;31mSIZE >= $alertTextSize\033[0m"
	elif [ $2 -ge $warnSize ]
	then
		echo -e "\033[1;33mSIZE >= $warnTextSize\033[0m"
	fi
	if [ $tmpSize -ge $alertMinSize ]
	then
		echo -e "\033[1;31mSIZE/MINUTE >= $alertMinTextSize\033[0m"
	elif [ $tmpSize -ge $warnMinSize ]
	then
		echo -e "\033[1;33mSIZE/MINUTE >= $warnMinTextSize\033[0m"
	fi
	echo ""

}

doBreak=0
for file in *
	do
		if [ -f "$file" ]
		then
			if [ ${file: -4} == ".avi" ] || [ ${file: -4} == ".mkv" ] || [ ${file: -4} == ".mp4" ]
			then
				if [ $doBreak == 1 ]
				then
					echo "----------------------------\n"
				else
					doBreak=1
				fi
				name=${file%%.*} # Strip extension
				size=$(stat --printf="%s" "$file") # Get total size in bytes
				length=$(ffprobe -i "$file" -show_entries format=duration -v quiet -of csv="p=0") # Get total length in seconds
				breakdown "$name" $size ${length%%.*}
			fi
		fi
	done
