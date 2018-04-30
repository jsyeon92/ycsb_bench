#!/bin/bash
memtablereps="skip_list cuckoo"
# prefix_hash hash_linkedlist"
workloads_run="A B C D E F"
workloads_load="Load_A Load_E"
buff_list="67108864 17179869184"
ops=100
ops2=10


function perf() {
		i=1
		buff=$1
		thread=1
		fname_run="ycsb_run_"$thread"_"$buff".dat"
		fname_load="ycsb_load_"$thread"_"$buff".dat"

		echo "# line workload mrep throughput" > $fname_run

		for workload in $workloads_run
		do
			for mem in $memtablereps
			do
				if [[ $workload == "Load_E" ]] || [[ $workload == "E" ]];
				then
					temp=$(grep -n "Throughput" "$mem"_"$workload"_"$ops2"_"$buff".perf | awk -F " " '{print $3}')
					if [[ -z $temp ]];
					then 
						temp=1
					fi
					echo "$i $workload $mem $temp"	
					echo "$i $workload $mem $temp" >> $fname_run

				else
					temp=$(grep -n "Throughput" "$mem"_"$workload"_"$ops"_"$buff".perf | awk -F " " '{print $3}')
					if [[ -z $temp ]];
					then 
						temp=1
					fi
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
					temp=$(grep -n "Throughput" "$mem"_"$workload"_"$ops2"_"$buff".perf | awk -F " " '{print $3}')
					if [[ -z $temp ]];
					then 
						temp=1
					fi
					echo "$i $workload $mem $temp"	
					echo "$i $workload $mem $temp" >> $fname_load

				else
					temp=$(grep -n "Throughput" "$mem"_"$workload"_"$ops"_"$buff".perf | awk -F " " '{print $3}')
					if [[ -z $temp ]];
					then 
						temp=1
					fi
					echo "$i $workload $mem $temp"	
					echo "$i $workload $mem $temp" >> $fname_load
				fi
				i=$((i+1))
			done
			i=$((i+1))
		done
}
for buf in 	$buff_list
do
	perf $buf
done
python2.7 3_perf_plot.py $fname_load
python2.7 3_perf_plot.py $fname_run
