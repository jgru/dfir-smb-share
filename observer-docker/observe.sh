#!/bin/bash

TSA="https://freetsa.org/tsr"
#TSA="https://zeitstempel.dfn.de"
tsr="tsr"

observe(){
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
	    fn=${f#$(dirname ${f})/}
	    # Echo filename
	    #echo "${fn} close_write"

	    # Ignore dot files
	    if ! [[ "$fn" =~ ^\..* ]];
	    then
		# Ignore files with suffix .${hash}
		if ! [[ $fn =~ .*\.($suf|$tsr)$ ]];
		then
		    # Calculate hash sum
		    eval ${hashsum} $f > "${f}.${suf}";
		    create_working_copy "${f}.${suf}"
		    create_working_copy "${f}"
		elif ! [[ $fn =~ .*\.($tsr)$ ]];
		     then
			 # Create openssl timestamp request by taking the hash of the hash file
			 # See: https://books.google.cz/books?id=pgYvDwAAQBAJ&printsec=frontcover&hl=cs&source=gbs_ge_summary_r&cad=0#v=onepage&q=openssl&f=false
			 # Pipe it to curl to submit b/m request to timestamping authoriy
			 openssl ts -query -data $f -cert| \
			     curl -s -H "Content-Type: application/timestamp-query" --data-binary @- \
				  "$TSA" > $f.$tsr

			 # Initiate copy to work_dir after checksum and timestamp are created
			 create_working_copy "${f}.${tsr}"
		fi
	    fi
	fi
    done
}

create_working_copy(){
    local dhash=""
    local src=$1
    local shash=$(eval ${hashsum} ${src} | awk '{print $1}')

    # Make sure, that hashes of src and dst match, otherwise retry
    while [[ ${dhash} != ${shash} ]]
    do
	dhash=$(hcopy ${src})
    done;
}

hcopy() {
    local src=$1
    local rel_path=${src#${watch_dir}}
    local dst=${work_dir}${rel_path}

    #echo "Creating dir: $(dirname ${dst}) and starting copy"
    mkdir -p $(dirname ${dst})
    cp ${src} ${dst}

    # Return hash of copied file
    local result_hash=$(eval ${hashsum} ${dst} | awk '{print $1}')
    echo ${result_hash}
}

############################################################################
# Main program
# Uses positional arguments:
# $1 = dir to observe
# $2 = dir to copy to
# $3 hashing method to use (md5sum, sha256sum,...)
############################################################################

hashsum=$3
if ! [[ $hashsum ]]
then
    hashsum="md5sum"
fi

watch_dir=$1
work_dir=$2

observe
