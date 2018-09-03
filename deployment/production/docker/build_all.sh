#!/usr/bin/env bash

services=(enketo_express kobocat kpi mongo nginx postgres rabbit redis_cache redis_main)

cur_dir=$PWD
export BUILD_ARGS="--no-cache"

for serv in "${services[@]}"
do
	cd $cur_dir/$serv
	./build.sh
done
