#!/bin/sh

# this line specifies which gap is to be used
gap_str=$(which gap)

# execute ScanPreparer and find path to Scan file
$gap_str ScanPreparerNoCronjobs.gi

# read in variables from tmp files
path=`cat path.txt`
threads=`cat threads.txt`
compsPerThread=`cat compsPerThread.txt`
lapse=`cat lapse.txt`

# remove tmp files
$(which rm) path.txt
$(which rm) threads.txt
$(which rm) compsPerThread.txt
$(which rm) lapse.txt

# form variable to tell if the computation is finished
overall=$(($threads * $compsPerThread - 1))

# start loop
finished=false
while ( ! $finished )
do
    
    # execute gap scanner for 5 minutes then stop it
    timeout "${lapse}s" $gap_str $file_path
    
    # remove tmp-files
    rm -rf $(find /tmp -name 'gap_4ti2*' -execdir pwd \; )
    
    # read out status of all threads - save them to an array and write log-file
    total=0
    $(which date) >> "$path/MyScan.log"
    for i in $(seq 1 $threads); do
        echo "Scan$i:" >> "$path/MyScan.log"
        status_file="$path/Scan$i/StatusOfRun$i.txt"
        $(which cat) "$path/Scan$i/StatusOfRun$i.txt" >> "$path/MyScan.log";
        thread_status=$(cat "$status_file")
        total=$((total+thread_status))
    done
    echo "\n" >> "$path/MyScan.log"
    
    # check if computation is finished to stop loop
    if [ "$total" -gt "$overall" ]
    then
        finished=true
        echo "computation finished"
    fi
    
done
