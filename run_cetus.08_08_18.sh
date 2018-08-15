#!/bin/bash
#source ~/.bashrc
#source activate match_pvalue_simulations

# TODO Check for existence of config.yaml and cluster.yaml

# TODO Optional parameters to specify config and cluster files

############

date

dir=/Genomics/grid/users/abwolf/SimulatedDemographic/MatchPvalue/bin
snakefile = $( echo $dir/Snakefile)
snakefile_db=$( echo $dir/snake.create_db )
snakefile_matchpval=$( echo $dir/snake.calc_matchpval )
clusterconfigfile=$( echo $dir/cetus_cluster.yaml )
configfile=$( echo $dir/config_0.05_pct.yaml )

############
echo $dir
echo $snakefile
echo $clusterconfigfile
echo $configfile

snakemake \
		--snakefile $snakefile \
		--cluster-config $clusterconfigfile \
		--configfile $configfile \
		--rerun-incomplete \
        --drmaa " --cpus-per-task={cluster.n} --mem={cluster.memory} --qos={cluster.qos}" \
        --use-conda -w 60 -rp -j 50 "$@"


#
# snakemake \
# 		--snakefile $snakefile_db \
# 		--cluster-config $clusterconfigfile \
# 		--configfile $configfile \
# 		--rerun-incomplete \
#         --drmaa " --cpus-per-task={cluster.n} --mem={cluster.memory} --qos={cluster.qos}" \
#         --use-conda -w 60 -rp -j 50 "$@"
#
# ############
#
# echo $snakefile_matchpval
#
# snakemake \
# 		--snakefile $snakefile_matchpval \
# 		--cluster-config $clusterconfigfile \
# 		--configfile $configfile \
#         --drmaa " --cpus-per-task={cluster.n} --mem={cluster.memory} --qos={cluster.qos}" \
#         --use-conda -w 60 -rp -j 50 "$@"

date
