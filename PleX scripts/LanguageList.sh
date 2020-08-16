#!/bin/bash

: '
Lists track language of every movie or show.
For TV shows, the script will attempt to handle each season as 1 file, but will fallback to individual files if at least one files track language is different.

Use -q to suppress output
'

suppressOut=0
while getopts ":q" opt; do
	case $opt in
		q)
			suppressOut=1
			;;
		\?)
			echo "Ignoring invalid option: -$OPTARG"
			;;
	esac
done

toFixLocation="/home/dj/scripts/toFix.txt"
doBreak=0
if [ -f $toFixLocation ]; then
	rm $toFixLocation
fi
for file in *
	do
		if [ -f "$file" ]
		then
			if [ ${file: -4} == ".avi" ] || [ ${file: -4} == ".mkv" ] || [ ${file: -4} == ".mp4" ]
			then
				sendToDoFix=0
				audioStreamText=""
				subtitleStreamText=""
				if [ $doBreak == 1 ]
				then
					if [ $suppressOut == 0 ]
					then
						echo "----------------------------\n"
					fi
				else
					doBreak=1
				fi
				if [ $suppressOut == 0 ]
				then
					echo "Movie: ${file%%.*}"
				fi
				audioStreams=("")
				while IFS= read -r line; do
					audioStreams+=( "$line" )
				done < <( ffprobe "$file" -show_entries stream=index:stream_tags=language -select_streams a -of compact=p=0:nk=1 -v quiet )
				if [ $suppressOut == 0 ]
				then
					echo "Audio Streams:"
				fi
				for i in ${audioStreams[@]}
				do
					if [ ${#i} != 1 ] && [ ${i:2} != "und" ]
					then
						if [ $suppressOut == 0 ]
						then
							echo ${i:2}
						fi
					else
						if [ $suppressOut == 0 ]
						then
							echo -e "\033[1;33mUnknown language\033[0m"
						fi
						sendToDoFix=1
						audioStreamText+="${i:0:1}"
					fi
				done

				subtitleStreams=("")
				while IFS= read -r line; do
					subtitleStreams+=( "$line" )
				done < <(ffprobe "$file" -show_entries stream=index:stream_tags=language -select_streams s -of compact=p=0:nk=1 -v quiet)
				if [ ${#subtitleStreams[*]} -gt 1 ]
				then
					if [ $suppressOut == 0 ]
					then
						echo "Subtitle Streams:"
					fi
					if [ ${#subtitleStreams[*]} -gt 2 ]
					then
						sendToDoFix=1
					fi
					for i in ${subtitleStreams[@]}
					do
						if [ ${#i} != 1 ] && [ ${i:2} != "und" ]
						then
							if [ $suppressOut == 0 ]
							then
								echo ${i:2}
							fi
						else
							if [ $suppressOut == 0 ]
							then
								echo -e "\033[1;33mUnknown language\033[0m"
							fi
							sendToDoFix=1
							subtitleStreamText+="${i:0:1}"
						fi
					done
				fi
				if [ $sendToDoFix == 1 ]
				then
					printf "$file" >> $toFixLocation
					if [ ${#audioStreamText} -gt 0 ]
					then
						printf "|a$audioStreamText" >> $toFixLocation
					fi
					if [ ${#subtitleStreamText} -gt 0 ]
					then
						printf "|s$subtitleStreamText" >> $toFixLocation
					fi
					printf "\n" >> $toFixLocation
					echo "Saved ${file%%.*} to log"
				fi
				if [ $suppressOut == 0 ]
				then
					echo ""
				fi
			fi
		fi
	done
