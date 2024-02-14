#!/bin/bash

for (( counter=1; counter<=40; counter++ ))
do  
   echo "processing data_season_$counter.txt"
	cat data_season_$counter.txt >> wheel.txt 
done
