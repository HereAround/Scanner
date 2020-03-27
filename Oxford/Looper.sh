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
    for i in $(seq 1 $threads); do
        
        # form path to scan file
        file_path="$path/Scan$i/Scan.gi"
        
        # start background job
        #(timeout "${lapse}s" $gap_str $file_path) &
        ($gap_str $file_path) &
        
    done
    sleep 20
    #wait
    
    #some_command &
#P1=$!
#other_command &
#P2=$!
#wait $P1 $P2
    
    # but we need to run potentially several gaps in parallel for this limited time and not sequentially after each other!
    # See https://www.cyberciti.biz/faq/how-to-run-command-or-code-in-parallel-in-bash-shell-under-linux-or-unix/
    # -> so essentially just place & at the end for a background job and done
    
    # read out status of all threads - save them to an array and write log-file
    total=0
    $(which date) >> "$path/MyScan.log"
    for i in $(seq 1 $threads); do
        
        # set up status file
        status_file="$path/Scan$i/StatusOfRun$i.txt"
        
        # write to log file
        echo "Scan$i:" >> "$path/MyScan.log"
        $(which cat) "$path/Scan$i/StatusOfRun$i.txt" >> "$path/MyScan.log";
        echo "\n" >> "$path/MyScan.log"
        
        # increase total-counter
        thread_status=$(cat "$status_file")
        total=$((total+thread_status))
    done
    
    # check if computation is finished to stop loop
    #if [ "$total" -gt "$overall" ]
    if [ "$total" -gt 0 ]
    then
        finished=true
        echo "computation finished"
    fi
    
done
