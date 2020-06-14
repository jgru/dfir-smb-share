#!/bin/bash
# you might want to change the directory below into the targeted directory
DIR=$1
SUF='sha256'
SUF2='tsr'
#TSA='https://freetsa.org/tsr'
TSA='https://zeitstempel.dfn.de'

# Run inotify
# -m = monitor mode; run indefinitely
# -r = recursively
# -e = specify kind of events; here: move and create
# --format '%w%f' prints path to the file (%w) and the filename (%f), that changed
inotifywait -m -e close_write --format '%w%f' "$DIR" | while read f
do
    if [[ -f $f ]];
    then
	fn=$(basename "$f")

	# Echo basename
	echo $fn

	if [[ "$fn" =~ ^\..* ]];
	then
	    echo "Dotfile - Do nothing";
	    #echo "$f.sha256"
	    #shasum -a 256 $f > $f.sha256
	elif ! [[ $fn =~ .*\.($SUF|$SUF2)$ ]];
	then

	    # Calculate hash sum
	    shasum -a 256 $f > "$f.$SUF";
	    # Create openssl timestamp request by taking the hash of the hash file
	    # See: https://books.google.cz/books?id=pgYvDwAAQBAJ&printsec=frontcover&hl=cs&source=gbs_ge_summary_r&cad=0#v=onepage&q=openssl&f=false
	    # Pipe it to curl to submit b/m request to timestamping authoriy
	    openssl ts -query -data $f.$SUF -cert| \
	    curl -s -H "Content-Type: application/timestamp-query" --data-binary @- \
	    "$TSA" > $f.$SUF.$SUF2
	fi
    fi
done
