#!/bin/bash
DATA_DIR=/mnt/ssd
ARDB_DIR=/home/ubuntu/ardb
YCSB_DIR=/home/ubuntu/YCSB
RESULT_DIR=/home/ubuntu/ardb/ycsb_bench/tmp
#DEVICE_PATH=/dev/xvdf1
ROCKSDB_ENGINE=/home/ubuntu/ardb/src/db/rocksdb
DEVICE_PATH=/dev/nvme1n1p1
#memtables="skip_list cuckoo prefix_hash hash_linkedlist"
#memtables="cuckoo"
memtables="skip_list cuckoo"
#memtables="prefix_hash hash_linkedlist"
buff_list="67108864"
#buff_list="11111100"
#buff_list="17179869184" 
# 17179869184" 
ops=100
ops_insert=1000000 #1M
  
ops2=10
ops2_insert=1000000 #1M
function main() {
#mount ssd
	pkill ardb-server
	umount $DATA_DIR
	mount $DEVICE_PATH $DATA_DIR
	rm -r $DATA_DIR/*
	free && sync && echo 3 > /proc/sys/vm/drop_caches && free

	sleep 1 
#configuration setting
	if [[ $1 == "skip_list"  ]];
	then
		echo "=================$1===================="
		sed -i '/memtable\_factory\=/d' $ARDB_DIR/ardb.conf
		sed -i '64imemtable\_factory\='$1'\;write_buffer_size='$2'\;\\' $ARDB_DIR/ardb.conf
	elif [[ $1 == "cuckoo" ]];
	then
		echo "=================$1===================="
		sed -i '/memtable\_factory\=/d' $ARDB_DIR/ardb.conf
		sed -i '64imemtable\_factory\='$1'\:'$2'\;allow_concurrent_memtable_write\=0\;write_buffer_size='$2'\;report_bg_io_stats=1\;stats_dump_period_sec\=1\;\\' $ARDB_DIR/ardb.conf
	else 
		echo "=================$1===================="
		sed -i '/memtable\_factory\=/d' $ARDB_DIR/ardb.conf
		sed -i '64imemtable\_factory\='$1'\;allow_concurrent_memtable_write\=0\;write_buffer_size='$2'\;\\' $ARDB_DIR/ardb.conf
	fi
	
	sed -i '/m\_options\.write_buffer_size/d' $ROCKSDB_ENGINE/rocksdb_engine.cpp
	sed -i '780im\_options\.write\_buffer\_size\='$2'\;' $ROCKSDB_ENGINE/rocksdb_engine.cpp

	cd $ARDB_DIR
	./make.sh
	cd -

#run ardb-server
	cd $YCSB_DIR
	fname_log="$1"_Load_A_"$ops"_"$2".perf.log
	$ARDB_DIR/src/ardb-server $ARDB_DIR/ardb.conf > $RESULT_DIR/$fname_log &
	sleep 1
	cd -
#run YCSB work(a~f)
#load
	sed -i '/recordcount\=/d' $YCSB_DIR/workloads/workloadA
	sed -i '/operationcount\=/d' $YCSB_DIR/workloads/workloadA	
	sed -i '1irecordcount\='$ops_insert'' $YCSB_DIR/workloads/workloadA
	sed -i '2ioperationcount\='$ops_insert'' $YCSB_DIR/workloads/workloadA
	fname="$1"_Load_A_"$ops"_"$2".perf
#	mvn -pl com.yahoo.ycsb:redis-binding -am clean package 
	cd $YCSB_DIR
	./bin/ycsb load redis -s -P $YCSB_DIR/workloads/workloadA -p "redis.host=127.0.0.1" -p "redis.port=16379" > $RESULT_DIR/$fname
#run
	sleep 1
	for work in A B C D F
	do
		sed -i '/recordcount\=/d' $YCSB_DIR/workloads/workload$work
		sed -i '/operationcount\=/d' $YCSB_DIR/workloads/workload$work	
		sed -i '1irecordcount\='$ops'' $YCSB_DIR/workloads/workload$work
		sed -i '2ioperationcount\='$ops'' $YCSB_DIR/workloads/workload$work
		echo "=================$1 run workload $work===================="
		echo "=================$1 run workload $work====================" >> $RESULT_DIR/$fname_log
		fname="$1"_"$work"_"$ops"_"$2".perf
		./bin/ycsb run redis -s -P $YCSB_DIR/workloads/workload$work -p "redis.host=127.0.0.1" -p "redis.port=16379" >> $RESULT_DIR/$fname
		fname="$1"_"$work"_"$ops".perf.log
#		cp $DATA_DIR/rocksdb/LOG $RESULT_DIR/$fname
		sleep 1 
	done	
#delete rocsdb data
	
	pkill ardb-server
	rm -r $DATA_DIR/*
	free && sync && echo 3 > /proc/sys/vm/drop_caches && free
	sleep 1 
#run YCSB work(e)
	fname_log="$1"_Load_E_"$ops2"_"$2".perf.log
	$ARDB_DIR/src/ardb-server $ARDB_DIR/ardb.conf > $RESULT_DIR/$fname_log &
	sleep 1

	sed -i '/recordcount\=/d' $YCSB_DIR/workloads/workloadE
	sed -i '/operationcount\=/d' $YCSB_DIR/workloads/workloadE
	sed -i '1irecordcount\='$ops2_insert'' $YCSB_DIR/workloads/workloadE
	sed -i '2ioperationcount\='$ops2_insert'' $YCSB_DIR/workloads/workloadE
	fname="$1"_Load_E_"$ops2"_"$2".perf
	./bin/ycsb load redis -s -P $YCSB_DIR/workloads/workloadE -p "redis.host=127.0.0.1" -p "redis.port=16379" > $RESULT_DIR/$fname
	sleep 1 

	sed -i '/recordcount\=/d' $YCSB_DIR/workloads/workloadE
	sed -i '/operationcount\=/d' $YCSB_DIR/workloads/workloadE
	sed -i '1irecordcount\='$ops2'' $YCSB_DIR/workloads/workloadE
	sed -i '2ioperationcount\='$ops2'' $YCSB_DIR/workloads/workloadE
	echo "=================$1 run workload e===================="	
	echo "=================$1 run workload e====================" >> $RESULT_DIR/$fname_log
	fname="$1"_E_"$ops2"_"$2".perf
	./bin/ycsb run redis -s -P $YCSB_DIR/workloads/workloadE -p "redis.host=127.0.0.1" -p "redis.port=16379" >> $RESULT_DIR/$fname
	fname="$1"_E_"$ops2".perf.log
#	cp $DATA_DIR/rocksdb/LOG $RESULT_DIR/$fname
	sleep 1 

	pkill ardb-server
	cd -
}
if [[ $# -lt 1 ]]; then
	echo "start_bench!"	
fi
#rm tmp/*.perf 
#rm tmp/*.log
for mem in $memtables
do
	for buf in $buff_list
	do
		main $mem $buf
	done
done
cp 1_memtable.sh tmp/.
cp 2_perf.sh tmp/.
cp 3_perf_plot.py tmp/.
