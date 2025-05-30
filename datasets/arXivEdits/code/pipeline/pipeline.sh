set -ex

RAW_INPUT_FILE="raw_input_full_v2.json"
STEP1="step1_newsedits_sentence.json"
STEP2="step2_newsedits_edits.json"
STEP4="step4_edit_with_intention.json"

# step 0, download all models.

# echo "step 0: downloading all checkpoints."

# mkdir ../../checkpoints/
# git lfs install
# git clone https://huggingface.co/chaojiang06/arxiv-sentence-alignment ../../checkpoints/arxiv-sentence-alignment

# mkdir ../../checkpoints/arxiv_crf_models
# wget  -O ../../checkpoints/arxiv_crf_models/model_task2_epoch_2_state_dict_0910.pkl https://www.dropbox.com/s/vavnb20gc3qijpw/model_task2_epoch_2_state_dict_0910.pkl
# wget  -O  ../../checkpoints/arxiv_crf_models/model_task2_epoch_2_state_dict_0910_reverse_direction.pkl  https://www.dropbox.com/scl/fi/g517vo83ibbsywm9ww6py/model_task2_epoch_2_state_dict_0910_reverse_direction.pkl?rlkey=rz5f1irvw1xlwa4tkcbuliwqp

# echo "step 0: downloading done."


# # step 1, load the raw input file and perform sentence alignment.
# echo "step 1: sentence alignment."
# python ../aligner/CRF_aligner.py --input ${RAW_INPUT_FILE} --output ${STEP1} --threshold_adjustment -3.5 --direction bi-direction-union
# echo "step 1: sentence alignment done."

# step 2, extract edits from the aligned sentence pairs.
echo "step 2: edits extraction."
python ../edits/extract_edits.py --input ${STEP1} --output ${STEP2}
echo "step 2: edits extraction done."

# # step 3, run the intention classifier on the edits.
# echo "step 3: intention classification."
# python -u ../intention/run_translation_arxiv.py \
#   --model_name_or_path chaojiang06/arXivEdits-intention-classifier-T5-large-fine-grained \
#   --do_eval \
#   --do_predict \
#   --save_strategy epoch \
#   --evaluation_strategy epoch \
#   --load_best_model_at_end \
#   --num_train_epochs 10 \
#   --source_prefix "intent classification: " \
#   --train_file ../../data/edits/train.json\
#   --validation_file  ../../data/edits/dev.json\
#   --test_file ${STEP2}\
#   --output_dir ../intention/tmp \
#   --per_device_train_batch_size=12 \
#   --per_device_eval_batch_size=12 \
#   --metric_for_best_model accuracy \
#   --overwrite_output_dir \
#   --overwrite_cache \
#   --predict_with_generate

# echo "step 3: intention classification done."


# # step 4, merge the predicted intention with the edits, output the final file.
# echo "step 4: merge intentions into json file."
# python -u merge.py --input ${STEP2} --intention ../intention/tmp/generated_predictions.txt --output ${STEP4}
# echo "step 4: merge intentions into json file done."
