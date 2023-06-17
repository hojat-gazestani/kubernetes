#!/bin/bash

hosts='master worker1 worker2'

for host in $hosts;do
	ssh  user@$host < $1; 
done
