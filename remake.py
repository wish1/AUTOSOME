import sys

smth = open(sys.argv[1],"r")
input = open(TMP.txt,"r")
output = open(MasterList.txt,"w")
while input:
  line = smth.readline().split()
  paths = input.readline().split()
  if len(line) == 7:
    output.write(line[0] + ";" + line[1] + ";" + line[2] + ";" + line[3] + ";" + paths[0] + ";" + line[4] + ";" + paths[1] + ";" + paths[2] + ";" + paths[3] + ";" + paths[4] + ";" + line[5] + ";" + line[6] + ";" + paths[5] +"\n")
   else:
    output.write(line[0] + ";" +  line[1] + ";" +  line[2] + ";" + line[3] + ";" + paths[0] + ";" + line[4] + ";" + paths[1] + ";" + paths[2] + ";" + paths[3] + ";" + paths[4] + "\n")
