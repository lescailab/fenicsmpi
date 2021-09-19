OUTFILE=input.csv
echo "METHOD,DEGREE,CORES,STRESS" > $OUTFILE
for METHOD in "Newton" "BFGS"
do
        for DEGREE in 1 #2
        do
                for CORES in 1 2 4 #8 16
                do
                        for STRESS in "1e3" "5e3" "1e4" #"5e4"
                        do
                                echo "$METHOD,$DEGREE,$CORES,$STRESS" >> $OUTFILE
                        done
                done
        done
done
