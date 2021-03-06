# RandomScripts
This is a collection of my random scripts. Feel free to download, modify, and use any of these.

## Scripts
**TVScan.sh**: Use this script in your PleX TV Show directory to get a breakdown of all shows' counts, total sizes, and average sizes, and display warnings if the average size/episode is larger than pre-determined. Use the -b tag to get a breakdown by season, ignoring subdirectories. I recommend you pipe into the more commmand for readability, as this script generates a lot of output. Must be run in desired directory.

Example usages: `$ TVScan.sh` to list all shows' episode counts, total sizes, and average size/episode. `{PathToScript}/TVScan.sh -b` to list a breakdown by season and a total for show.

**renameTool.sh**: Use this basic script in a directory to rename all files to a uniform name. Make sure before running that the files are already in the desired order.

Example usage: `$ renameTool.sh "Cool Show S01E" .mkv` to rename all files to "Cool Show S01E01.mkv", "Cool Show S01E02.mkv", etc.

**MovieScan.sh**: Use this script in your PleX Movie Show directory to get a breakdown of all movies' total size, and average size/minute, and display warnings if the size or average size/min is larger than pre-determined. I recommend you pipe into the more commmand for readability, as this script generates a lot of output. Must be run in desired directory.

Example usages: `$ MovieScan.sh` to list all movies' total size, and average size/minute.

**batchRemux.sh**: Uses mkvmerge and a passed options file to remux mkv/mp4/avi files to remove unneeded/edit tracks from files, such as extra audio or subtitle tracks, or incorrect track language. -o {file}.json to specify options file. -d {directory} to specify output directory.

Example usages: `$ batchRemux.sh` to run with options file=options.json and output directory=mkvmerge_out