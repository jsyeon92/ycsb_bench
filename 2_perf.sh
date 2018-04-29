#!/bin/bash
memtablereps="skip_list cuckoo"
# prefix_hash hash_linkedlist"
workloads_run="A B C D E F"
workloads_load="Load_A Load_E"
fname_run="ycsdb_run_throught.dat"
fname_load="ycsdb_load_throught.dat"
i=1


echo "# line workload mrep throughput" > $fname_run

for workload in $workloads_run
do
	for mem in $memtablereps
	do
		if [[ $workload == "Load_E" ]] || [[ $workload == "E" ]];
		then
			temp=$(grep -n "Throughput" "$mem"_"$workload"_10.perf | awk -F " " '{print $3}')
			echo "$i $workload $mem $temp"	
			echo "$i $workload $mem $temp" >> $fname_run

		else
			temp=$(grep -n "Throughput" "$mem"_"$workload"_* | awk -F " " '{print $3}')
			echo "$i $workload $mem $temp"	
			echo "$i $workload $mem $temp" >> $fname_run
		fi
		i=$((i+1))
	done
	i=$((i+1))
done

i=1
echo "# line workload mrep throughput" > $fname_load

for workload in $workloads_load
do
	for mem in $memtablereps
	do
		if [[ $workload == "Load_E" ]] || [[ $workload == "E" ]];
		then
			temp=$(grep -n "Throughput" "$mem"_"$workload"_10.perf | awk -F " " '{print $3}')
			echo "$i $workload $mem $temp"	
			echo "$i $workload $mem $temp" >> $fname_run

		else
			temp=$(grep -n "Throughput" "$mem"_"$workload"_* | awk -F " " '{print $3}')
			echo "$i $workload $mem $temp"	
			echo "$i $workload $mem $temp" >> $fname_run
		fi
		i=$((i+1))
	done
	i=$((i+1))
done

python2.7 2_perf.sh $fname_load
python2.7 2_perf.sh $fname_run
