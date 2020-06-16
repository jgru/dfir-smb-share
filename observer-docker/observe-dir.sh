#!/bin/bash
# you might want to change the directory below into the targeted directory


TSA="https://freetsa.org/tsr"
#TSA="https://zeitstempel.dfn.de"
tsr="tsr"

observe(){
    local watch_dir=$1
    local work_dir=$2
    local hashsum=$3
    local suf=${hashsum%sum}  # remove sum

    # Run inotify
    # -m = monitor mode; run indefinitely
    # -r = recursively
    # -e = specify kind of events; here: move and create
    # --format '%w%f' prints path to the file (%w) and the filename (%f), that changed
    inotifywait -m -r -e close_write --format '%w%f' "${watch_dir}" | while read f
    do
	if [[ -f $f ]];
	then
	    fn=$(basename "$f")
	    # Echo basename
	    echo "${fn} close_write"

	    # Ignore dot files
	    if ! [[ "$fn" =~ ^\..* ]];
	    then
		# Ignore files with suffix .${hash}
		if ! [[ $fn =~ .*\.($suf)$ ]];
		then
		    # Calculate hash sum
		    eval ${hash} $f > "${f}.${suf}";

		elif ! [[ $fn =~ .*\.($tsr)$ ]];
		     then
			 # Create openssl timestamp request by taking the hash of the hash file
			 # See: https://books.google.cz/books?id=pgYvDwAAQBAJ&printsec=frontcover&hl=cs&source=gbs_ge_summary_r&cad=0#v=onepage&q=openssl&f=false
			 # Pipe it to curl to submit b/m request to timestamping authoriy
			 openssl ts -query -data $f.$suf -cert| \
			     curl -s -H "Content-Type: application/timestamp-query" --data-binary @- \
				  "$TSA" > $f.$suf.$SUF2

		fi
	    fi
	fi
    done
}

############################################################################
# Main program
# Uses positional arguments:
# $1 = observed_dir, $2 = dir to copy to, $3 hashing method
############################################################################

observe $1 $2 $3
