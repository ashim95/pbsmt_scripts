directory=$1
SRC=$2
TGT=$3


CONFIG_PATH=reverse_model_en-hi-iter-2/binarised/moses.ini

N_THREADS=14
# moses
MOSES_PATH=$PWD/moses_linux_64bit  # PATH_WHERE_YOU_INSTALLED_MOSES
TOKENIZER=$MOSES_PATH/scripts/tokenizer/tokenizer.perl
NORM_PUNC=$MOSES_PATH/scripts/tokenizer/normalize-punctuation.perl
INPUT_FROM_SGM=$MOSES_PATH/scripts/ems/support/input-from-sgm.perl
REM_NON_PRINT_CHAR=$MOSES_PATH/scripts/tokenizer/remove-non-printing-char.perl
TRAIN_TRUECASER=$MOSES_PATH/scripts/recaser/train-truecaser.perl
TRUECASER=$MOSES_PATH/scripts/recaser/truecase.perl
DETRUECASER=$MOSES_PATH/scripts/recaser/detruecase.perl
TRAIN_LM=$MOSES_PATH/bin/lmplz
TRAIN_MODEL=$MOSES_PATH/scripts/training/train-model.perl
MULTIBLEU=$MOSES_PATH/scripts/generic/multi-bleu.perl
MOSES_BIN=$MOSES_PATH/bin/moses


touch back_data.files_processed.txt
processed=back_data.files_processed.txt
nFiles=500
count=0

for FILENAME in $directory$SRC-in/*;do
    filename=$(basename $FILENAME)
    echo $filename

    val=$(grep $filename back_data.files_processed.txt | wc -l)

    if [[ "$val" -eq "0" ]]
    then
        echo "$filename" >> $processed
        echo "Going to translate file $filename"

        echo "Translating ... "
        $MOSES_BIN -threads $N_THREADS -f $CONFIG_PATH < $FILENAME > $directory$SRC-out/$filename.$TGT.hyp.true

        echo "Detruecasing ... "
        $DETRUECASER < $directory$SRC-out/$filename.$TGT.hyp.true > $directory$SRC-out/$filename.$TGT.hyp.tok

        count=$((count+1))
        if [[ "$count" -eq "$nFiles" ]]
        then
            echo "Finished translating $nFiles files."
            break
        fi
    else
        echo "File $filename already translated. Skipping !!"
    fi
done

echo "Done translating $nFiles files."


echo "Collecting information on all files ... "


sh match_lines.sh $directory$SRC-in $directory$SRC-out file_reprocess.txt

echo "Some files not translated correctly --- "
cat file_reprocess.txt

echo "No. of files not processed correctly --- "
echo "$(wc -l file_reprocess.txt | awk '{print $1}')"
