
# Script for training a supervised translation model for SRC-TGT pair


trainDir=$PWD/$1
SRC=$2
TGT=$3

LM_TGT=$PWD/$4

N_THREADS=48
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

MOSES_CLEAN=$MOSES_PATH/scripts/training/clean-corpus-n.perl



echo "TRAIN DIRECTORY  --  $trainDir"

if ! [[ -f "$trainDir/corpus.$SRC-$TGT.clean.$SRC" && -f "$trainDir/corpus.$SRC-$TGT.clean.$TGT" ]]; then

    echo "Cleaning the corpus ... "
    echo "Keeping length of sentences between 1 and 80"

    $MOSES_CLEAN $trainDir/corpus.$SRC-$TGT.true $SRC $TGT $trainDir/corpus.$SRC-$TGT.clean 1 80
fi

echo

echo "Using language model for language : $TGT from file : $LM_TGT"

echo

echo "Going to start training the translation model for pair $SRC-$TGT"


nohup nice $TRAIN_MODEL --root-dir $trainDir -cores $N_THREADS -corpus $trainDir/corpus.$SRC-$TGT.clean -f $SRC -e $TGT -alignment grow-diag-final-and -reordering msd-bidirectional-fe -lm 0:5:$LM_TGT:8 -external-bin-dir $MOSES_PATH/training-tools --mgiza --mgiza-cpus $N_THREADS > $trainDir/training-$SRC-$TGT.out 2>&1&
