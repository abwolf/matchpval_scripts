#!/bin/bash
#source ~/.bashrc
#source activate match_pvalue_simulations

# TODO Check for existence of config.yaml and cluster.yaml

# TODO Optional parameters to specify config and cluster files

############

date

dir=/Genomics/grid/users/abwolf/SimulatedDemographic/MatchPvalue/bin
snakefile=$( echo $dir/Snakefile)
clusterconfigfile=$( echo $dir/cetus_cluster.yaml )
configfile=$( echo $dir/config_ABC_test.yaml )

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


date
