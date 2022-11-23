#!/bin/bash
arm_gcc *.c -o bin/iot.run
scp bin/iot.run root@10.42.0.2:/home/root
ssh root@10.42.0.2
