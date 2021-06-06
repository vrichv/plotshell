#!/bin/bash
DISKS=(3a 3b 3c 3d 3e 3f 3g 3h 3i 2a)
LOGDIR=~/logs/chia
MAX_PHASE1_NUM=5
SLEEPTIME_FOR_NEXT_PLOT=600
SLEEPTIME_FOR_CHECK_LOG=300

plot_ssd1() {
    local disk=ssd1
    chia plots create -k32 -t/mnt/${disk} -d/mnt/wd14t3/chia -b3390 -u128 -r3 >${LOGDIR}/${disk}.txt 2>&1 &&
        mv ${LOGDIR}/${disk}.txt ${LOGDIR}/oldlog/${disk}-$(date +%Y%m%d)_$(date +%H%M%S).txt &&
        we "PLOT_${disk}_FINISH" &
}

print_log() {
    echo "$(date +%H:%M:%S) $1" >&2
    echo "$(date +%m-%d) $(date +%H:%M:%S) $1" >>/tmp/plotshell.log
}

notify_me() {
    we $1
}

check_space() {
    local disk=$1
    local avaspace=$(df -m /mnt/${disk} | grep -v Available | awk '{print $4}')
    if [ $avaspace -lt 245000 ]; then
        print_log "ERROR: Disk ${disk} is full."
        [ -f /tmp/plotshell-diskfull-${disk}.tmp ] || (notify_me "ERROR_DISK_${disk}_IS_FULL" && touch /tmp/plotshell-diskfull-${disk}.tmp && print_log "INFO: Send notify success.")
        return 1
    fi
}

check_phase1() {
    local p1_num=0
    local dis
    for dis in ${DISKS[@]}; do
        grep "Starting phase" ${LOGDIR}/${dis}.txt 2>/dev/null | tail -n1 | grep "1/4" && ((p1_num++))
    done

    if [ $p1_num -ge ${MAX_PHASE1_NUM} ]; then
        echo -n ">" >&2
        sleep $SLEEPTIME_FOR_CHECK_LOG
        check_phase1
    fi
}

[ -d ${LOGDIR}/oldlog ] || mkdir -p ${LOGDIR}/oldlog
rm /tmp/plotshell*.tmp >/dev/null 2>&1
chiastatus.sh
print_log "INFO: Checking disk >>> ${DISKS[*]} <<< in plot..."

while true; do
    for a in ${DISKS[@]}; do
        sleep 60
        echo -n ">"
        ps -ef | grep plots | grep /mnt/$a >/dev/null
        if [ $? = 0 ]; then
            continue
        fi
        #move old logfile
        [ -f ${LOGDIR}/${a}.txt ] && mv ${LOGDIR}/${a}.txt ${LOGDIR}/oldlog/${a}-$(date +%Y%m%d)_$(date +%H%M%S).txt

        #check disk
        check_space $a || continue
        # check phase1 num and wait
        echo ""
        print_log "INFO: Wating phase 1 plot number lower than $MAX_PHASE1_NUM ."
        check_phase1

        echo ""
        print_log "INFO: Prepare plot ${a}"
        if [ "$(type -t plot_${a})" == function ]; then
            plot_$a
        else
            chia plots create -k32 -t/mnt/${a} -d/mnt/${a} -b2640 -u128 -r2 >${LOGDIR}/${a}.txt 2>&1 &&
                mv ${LOGDIR}/${a}.txt ${LOGDIR}/oldlog/${a}-$(date +%Y%m%d)_$(date +%H%M%S).txt &&
                we "PLOT_${a}_FINISH" &
        fi

        sleep 10

        ps -ef | grep plots | grep /mnt/$a >/dev/null && grep "Starting phase" ${LOGDIR}/${a}.txt >/dev/null 2>&1
        if [ $? = 0 ]; then
            print_log "INFO: Starting plot ${a}..."
            #wait 10min to launch next plot
            sleep $SLEEPTIME_FOR_NEXT_PLOT
        else
            print_log "ERROR: Starting plot ${a} failed."
        fi

    done
done
