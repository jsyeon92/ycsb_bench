#!/bin/bash
memtablereps="skip_list cuckoo prefix_hash hash_linkedlist"
workloads="Load_A A B C D Load_E E F"
fname="ycsdb_throught.dat"
i=1


echo "# line workload mrep throughput" > $fname

for workload in $workloads
do
	for mem in $memtablereps
	do
		if [[ $workload == "Load_E" ]] || [[ $workload == "E" ]];
		then
			temp=$(grep -n "Throughput" "$mem"_"$workload"_10.perf | awk -F " " '{print $3}')
			echo "$i $workload $mem $temp"	
			echo "$i $workload $mem $temp" >> $fname

		else
			temp=$(grep -n "Throughput" "$mem"_"$workload"_* | awk -F " " '{print $3}')
			echo "$i $workload $mem $temp"	
			echo "$i $workload $mem $temp" >> $fname
		fi
		i=$((i+1))
	done
	i=$((i+2))
done


python2.7 3_perf_plot.py $fname

