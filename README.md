# `Plotshell`: a small chia plotting tool for hdd plotting.
This simple scripts is used to automate the batch plotting of multi HDDs.   
Since I have 2 old machines and don't want to burn out my SSD,I decide to using hard disks for plotting and write this scripts ,if you are using SSDs for plotting, other tools may be more suitable.

## Key Points of HDD plotting 
- DO NOT use windows, windows is not suitable for multi-HDDs plotting scenarios, you need special software to assist.
- DO NOT use RAID. Multiple HDDs configured as raid0 for plotting is a bad idea, if you are using a RAID card, set it to pass-through/HBA mode.
- Multi-disk plotting does not require high-performance CPU & Memory, high-performance machines are not much faster.
- You don't need to allocate too much memory and threads each time, 2640M memory and 2 or 3 threads is ok.
- Normally, one plot process per HDD.
- The maximum number of concurrent per batch depends on the number of cpu threads, usually is (total_number_of_cpu_threads/3 ). For example, a 20-thread cpu with a maximum of 6 HDD plotting process (2 threads per process) concurrently in the phase 1, and memory must be larger than 2640M\*6\*2 ,if also run full_node service or GUI on the same machine, you must have more memory, don't let the system use swap space,this is very important!!!
- If you need more details and help, leave a message in the Discussions board. 

## How to use
1. Format your disk, xfs is recommended.
2. mount all your disk to /mnt, one directory per disk, as below:
```
$ lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda           8:0    0   2.7T  0 disk 
└─sda1        8:1    0   2.7T  0 part /mnt/3a
sdb           8:16   0   2.7T  0 disk 
└─sdb1        8:17   0   2.7T  0 part /mnt/3b
sdc           8:32   0   1.8T  0 disk 
└─sdc1        8:33   0   1.8T  0 part /mnt/2a
sdd           8:48   0   2.7T  0 disk 
└─sdd1        8:49   0   2.7T  0 part /mnt/3c
```
3. Copy this scripts to  $HOME/bin/
4. Change the parameters in the script
```
DISKS=(3a 3b 3c 2a)          =>  The directorys where the disks is mounted
LOGDIR=~/logs/chia
MAX_PHASE1_NUM=5             =>  Maximum number of concurrency in the phase 1,this number is usually set to (total_number_of_cpu_threads/3 )
SLEEPTIME_FOR_NEXT_PLOT=600
SLEEPTIME_FOR_CHECK_LOG=300
```
5. Run this script in a `screen` terminal.
6. Turn off the monitor and go to sleep.
7. When the hard drive is full, move disks to the farming machine, or keep it if you plotting and farming on the same machine.
8. CTRL+C to quit, and kill all `plotshell.sh` , `chia plots create` process,delete all `plot*.tmp` files in /mnt/.

## For developer
1. In the script , the `we` program is a private program that sends notifications to my phone, you can change it to any program that sends email/SMS notifications to you.
2. You can customize the parameters of each HDD plotting process with custom function plot_<disk_mountdir_name> .

## TODO list
- Detecting hung processes of plotting.
- Extract the configuration parameters into a config file.

## Results of the battle
In the past month, I have run this script on 2 old machines and got 2 XCH.
```
$ chia farm summary
Farming status: Farming
Total chia farmed: 2.0
User transaction fees: 0.0
Block rewards: 2.0
Last height farmed: 377693
```

## Donation
If you like this tool, there are lots of ways :)
- Fork, star, donate
- My chia wallet address: `xch1uulql06zccvqhreyrkmckn3t6g6thxsugnz5924pa3wxcpw0xjzseetel5` 

Good luck!  
