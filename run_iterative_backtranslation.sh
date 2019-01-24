SRC=$1
TGT=$2
iterNo=3

directory=data/mono/
data_dir=back_translation

#sh generate_back_data.sh $directory $SRC $TGT

echo "Going to start traning a reverse translation model $TGT-$SRC "

mkdir -p reverse_model_$TGT-$SRC-iter-$iterNo


if ! [[ -f "reverse_model_$TGT-$SRC-iter-$iterNo/corpus.$TGT-$SRC.true.$SRC" && -f "reverse_model_$TGT-$SRC-iter-$iterNo/corpus.$TGT-$SRC.true.$TGT" ]]; then
    echo "Copying truecased back-translated data "
    cp $data_dir/all.clean.$SRC-$TGT.$SRC.true reverse_model_$TGT-$SRC-iter-$iterNo/corpus.$TGT-$SRC.true.$SRC
    cp $data_dir/back.all.noisy.$SRC-$TGT.$TGT.true reverse_model_$TGT-$SRC-iter-$iterNo/corpus.$TGT-$SRC.true.$TGT
fi

LM_DIR=data/

TRAIN_DIR=reverse_model_$TGT-$SRC-iter-$iterNo
LM_FILE=$LM_DIR$SRC.lm.blm


echo "Files and directories ready... Starting..."

# Since training a reverse model, hence switching the language pair
sh train_supervised.sh $TRAIN_DIR $TGT $SRC $LM_FILE
