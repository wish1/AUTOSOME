#!/bin/bash
#maketunnel
#ssh -L 1235:autosome.dote.ru:60011 abramov@globe.autosome.ru cat -

#usage bash download.sh /home/Abramov/REFERENCE /home/Abramov/REFERENCE/00-common_all.vcf.gz num
REF=$1
VCF=$2
Num=$3
n=0
ALIGNCTRL=false

while read LINE; do
	if $n==$Num;then
		IFS='	'
		read -ra ADDR <<< $LINE
		if [ ${ADDR[2]}=="Homo sapiens" ]; then
			if ${#arr[*]}==11;then
				EXP=${ADDR[0]}
				echo "making $EXP with ctrl"
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
			else:
				EXP=${ADDR[0]}
				echo "making $EXP without ctrl"
				TF=${ADDR[1]}
				ALIGNEXP=${ADDR[3]}
				ALIGNPATH=${ADDR[4]}
				PEAKS=${ADDR[5]}
				MACS=${ADDR[6]}
				SISSRS=${ADDR[7]}
				CPICS=${ADDR[8]}
				GEM=${ADDR[9]}
			fi
		fi
	
		if ! [ -d /home/Abramov/Alignments/"$TF" ]; then
			mkdir /home/Abramov/Alignments/"$TF"
			if [ $? != 0 ]; then
				echo "Failed to make dir"
	    			exit 1
			fi
		fi
	
		mkdir /home/Abramov/Alignments/"$TF/$EXP"
		if [ $? != 0 ]; then
			echo "Failed to make dir"
	    		exit 1
		fi
		
		scp -P 1235  autosome@127.0.0.1:$ALIGNPATH /home/Abramov/Alignments/"$TF/$EXP/$ALIGNEXP.bam"
		if [ $? != 0 ]; then
			echo "Failed to download ALIGNEXP $EXP"
	    		exit 1
		fi
		
		scp -P 1235  autosome@127.0.0.1:$MACS /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_macs.interval"
		if [ $? != 0 ]; then
			echo "Failed to download MACS $EXP"
	    		exit 1
		fi
		
		scp -P 1235  autosome@127.0.0.1:$SISSRS /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_sissrs.interval"
		if [ $? != 0 ]; then
			echo "Failed to download SISSRS $EXP"
	    		exit 1
		fi
		
		scp -P 1235  autosome@127.0.0.1:$CPICS /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_cpics.interval"
		if [ $? != 0 ]; then
			echo "Failed to download CPICS $EXP"
	    		exit 1
		fi
		
		scp -P 1235  autosome@127.0.0.1:$GEM /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_gem.interval"
		if [ $? != 0 ]; then
			echo "Failed to download GEM $EXP"
	    		exit 1
		fi
		
		if $ALIGNCTRL; then
			scp -P 1235  autosome@127.0.0.1:$CTRLPATH /home/Abramov/Alignments/"$TF/$EXP/$ALIGNCTRL.bam"
			if [ $? != 0 ]; then
				echo "Failed to download ALIGNCTRL $EXP"
	    		exit 1
			fi
		fi
		
		#fix 2 versions of SNPcalling
		if $ALIGNCTRL; then
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
			if [ $? != 0 ]; then
				echo "Failed SNPcalling $EXP"
	    			exit 1
			fi
		else
			bash SNPcalling.sh -Ref $REF \
				-Exp /home/Abramov/Alignments/"$TF/$EXP/$ALIGNEXP.bam" \
				-WGE \
				-VCF $VCF \
				-Out /home/Abramov/Alignments/"$TF/$EXP" \
				-macs /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_macs.interval" \
				-sissrs /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_sissrs.interval" \
				-gem /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_gem.interval" \
				-cpics /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_cpics.interval"
			if [ $? != 0 ]; then
				echo "Failed SNPcalling $EXP"
	    			exit 1
			fi
			
			rm /home/Abramov/Alignments/"$TF/$EXP/$ALIGNCTRL.bam"
		
		fi
		
		
		rm /home/Abramov/Alignments/"$TF/$EXP/$ALIGNEXP.bam"	
		rm /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_macs.interval"
		rm /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_sissrs.interval"
		rm /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_gem.interval"
		rm /home/Abramov/Alignments/"$TF/$EXP/${PEAKS}_cpics.interval"
	fi
		n=$n+1
done < ./MasterList.txt
