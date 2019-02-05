#!/bin/bash
#maketunnel
#ssh -L 1235:autosome.dote.ru:60011 abramov@globe.autosome.ru cat -

#usage bash download.sh /home/Abramov/REFERENCE /home/Abramov/REFERENCE/00-common_all.vcf.gz num
REF=$2
VCF=$3
Num=$4
n=0
while read LINE; do
	if n==Num;then
		IFS='	'
		read -ra ADDR <<< $LINE
		if [ ${ADDR[2]}=="Homo sapiens" ]; then
			if [ ${ADDR[3]} != "None" ]; then
				EXP=${ADDR[0]}
				echo $EXP
				TF=${ADDR[1]}
				ALIGNEXP=${ADDR[3]}
				ALIGNPATH=${ADDR[4]}
				PEAKS=${ADDR[5]}
				MACS=${ADDR[6]}
				SISSRS=${ADDR[7]}
				CPICS=${ADDR[8]}
				GEM=${ADDR[9]}
				ALIGNCTRL=${ADDR[10]}
				CTRLPATH=${ADDR[11]}
			fi
		fi
	
		if ! [ -d /home/Abramov/Alignments/"$TF" ]; then
			mkdir /home/Abramov/Alignments/"$TF"
		fi
	
		mkdir /home/Abramov/Alignments/"$TF/$EXP"
	
		if [ $? != 0 ]; then
		    echo "Failed to make dir"
	    	exit 1
		fi
		
		scp -P 1235  autosome@127.0.0.1:$ALIGNPATH /home/Abramov/Alignments/"$TF/$EXP/$ALIGNEXP.bam"
		
		scp -P 1235  autosome@127.0.0.1:$MACS /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_macs.interval"
		scp -P 1235  autosome@127.0.0.1:$SISSRS /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_sissrs.interval"
		scp -P 1235  autosome@127.0.0.1:$CPICS /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_cpics.interval"
		scp -P 1235  autosome@127.0.0.1:$GEM /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_gem.interval"
	
		if $ALIGNCTRL; then
			scp -P 1235  autosome@127.0.0.1:$CTRLPATH /home/Abramov/Alignments/"$TF/$EXP/$ALIGNCTRL.bam"
		fi
	
		if [ $? != 0 ]; then
		    echo "Failed to download $EXP"
		fi
		#fix 2 versions of SNPcalling
		bash SNPcalling.sh -Ref $REF \
				-Exp /home/Abramov/Alignments/"$TF/$EXP/$ALIGNEXP.bam" \
				-Ctrl /home/Abramov/Alignments/"$TF/$EXP/$ALIGNCTRL.bam" \
				-WGE \
				-WGC \
				-VCF $VCF \
				-Out /home/Abramov/Alignments/"$TF/$EXP" \
				-macs /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_macs.interval" \
				-sissrs /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_sissrs.interval" \
				-gem /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_gem.interval" \
				-cpics /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_cpics.interval"
		
		rm /home/Abramov/Alignments/"$TF/$EXP/$ALIGNEXP.bam"
		rm /home/Abramov/Alignments/"$TF/$EXP/$ALIGNCTRL.bam"
		rm /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_macs.interval"
		rm /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_sissrs.interval"
		rm /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_gem.interval"
		rm /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_cpics.interval"
	fi
		n=$n+1
done < ./MasterList.txt

