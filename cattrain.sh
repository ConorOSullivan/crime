METHOD="learn"
FILE="category_testing.csv"
ARFF="cat_predict.arffh"



../wiserf/2/bin/wiserf2-openmp $METHOD \
	--in-file $FILE \
	--arff-header-file $ARFF \
	--label-name Category \
	--model-file cat_model.model \
	--log-file cat_predict_log.txt \
	--skip-data-lines 1  \
	--selection-file category_selections.txt \
	--feature-importances-file cat_featimp.txt	\
	--feature-importances-method gini \
	--num-trees 500	
