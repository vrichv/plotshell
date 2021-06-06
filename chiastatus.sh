chia show -cs
chia farm summary
chia wallet show
rm /tmp/chiastatus.txt >/dev/null 2>&1
cd ~/logs/chia/

#for a in `ls ~/Desktop/*.log`;
for a in  {3a,3b,3c,3d,3e,3f,3g,3h,3i,2a}.txt ;
do 
   echo "$a DISK:"
   grep "Starting phase" $a |tail -n1 |tee -a /tmp/chiastatus.txt;
done
echo "=========PHASE 1============="
grep "1/4" /tmp/chiastatus.txt|wc -l
echo "=========PHASE 2============="
grep "2/4" /tmp/chiastatus.txt|wc -l
echo "=========PHASE 3============="
grep "3/4" /tmp/chiastatus.txt|wc -l
echo "=========PHASE 4============="
grep "4/4" /tmp/chiastatus.txt|wc -l
echo "============================="
rm /tmp/chiastatus.txt
