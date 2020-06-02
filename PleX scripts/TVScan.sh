#!/bin/bash

: '
Prints TV show size, episode count, size/episode, and a breakdown by season
Should only be run in directories for Plex TV shows
Does not enter subdirectories

Use -b flag for show breakdown
It is recommended to pipe to the more command for readability, as this script produces a lot of output. Example usage ./TVScan.sh -b | more
'

# Change these vars if you want different warn and alert sizes
warnSize=750000000
alertSize=1000000000
warnTextSize="0.75GB"
alertTextSize="1GB"

breakdown () { # title (Season/Show), name, size, count
	echo "$1: $2"
	paddedSize=$(printf %9s $3)
	echo "Total Size: ${paddedSize:0:-9}.${paddedSize: -9} GB"
	echo "Episode Count: $4"
	tmpSize=$(($3 / $4))
	sizepep=$(printf %9s $tmpSize)
	echo "Size/Episode: ${sizepep:0:-9}.${sizepep: -9}"
	if [ $tmpSize -ge $alertSize ]
	then
		echo -e "\033[1;31mSIZE/EPISODE >= $alertTextSize\033[0m"
	elif [ $tmpSize -ge $warnSize ]
	then
		echo -e "\033[1;33mSIZE/EPISODE >= $warnTextSize\033[0m"
	fi
	echo ""

}

# Check if b tag is present for breakdown
doBreakdown=0
while getopts ":b" opt; do
	case $opt in
		b)
			doBreakdown=1
			;;
		\?)
			echo "Ignoring invalid option: -$OPTARG"
			;;
	esac
done

size=0
count=0
seasonSize=0
seasonCount=0
showName=""
season=""
flag=0
for file in *
	do
		if [ -f "$file" ]
		then
			parsedName=${file%%.*} # Strip extension

			# Check if this file is a combined episode file, i.e. has a dash in the episode identifier
			combinedEpisodes=0
			if [ ${parsedName:$((${#parsedName} - 4)):1} == "-" ]
			then
				combinedEpisodes=4
				seasonCount=$((seasonCount + ($((10#${parsedName:$((${#parsedName} - 2)):2})) - $((10#${parsedName:$((${#parsedName} - 6)):2})))))
			fi

			parsedSeason=${parsedName:$((${#parsedName} - (5 + $combinedEpisodes))):2} # Get season
			parsedName=${parsedName:0:$((${#parsedName} - (7 + $combinedEpisodes)))} # Remove season and episode identifier
			if [ "${showName,,}" != "${parsedName,,}" ] # New Show
			then
				if [ $flag == 1 ]
				then
					count=$((count + $seasonCount))
					size=$((size + $seasonSize))
					if [ $count -gt 0 ]
					then
						if [ $doBreakdown == 1 ]
						then
							echo "Show: $showName"
							breakdown Season $season $seasonSize $seasonCount
						fi
						breakdown Show "$showName" $size $count
					fi
					echo "----------------------------"
					count=0
					size=0
					seasonCount=0
					seasonSize=0
				else
					flag=1
				fi
				showName="$parsedName"
				season="$parsedSeason"
			elif [ $season != $parsedSeason ] # Same show, new season
			then
				if [ $doBreakdown == 1 ]
				then
					echo "Show: $showName"
					breakdown Season $season $seasonSize $seasonCount
				fi
				season="$parsedSeason"
				count=$((count + $seasonCount))
				size=$((size + $seasonSize))
				seasonSize=0
				seasonCount=0
			fi
			((seasonCount++))
			seasonSize=$((seasonSize + $(stat --printf="%s" "$file")))
		fi
	done
count=$((count + $seasonCount))
size=$((size + $seasonSize))
if [ $doBreakdown == 1 ]
then
	echo "Show: $showName"
	breakdown Season $season $seasonSize $seasonCount
fi
breakdown Show "$showName" $size $count
