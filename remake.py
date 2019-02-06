import sys

smth = open(sys.argv[1],"r")
input = open(TMP.txt,"r")
output = open(MasterList.txt,"w")
for line in input:
  line = line.split(" ")
  output.write(
