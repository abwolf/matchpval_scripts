
mdl=$( echo Tenn )
data_dir=/Genomics/akeylab/abwolf/SimulatedDemographic/Sstar/test/multi_sample
admix=$( echo 0.05_pct)
chromsize=$( echo 10000000)
configfile=$( echo config_$admix.yaml)

echo '
 output_directory: "'$data_dir'/match_pvalue"
 window_size: "50000"
 window_step_size: "10000"
 informative_site_method: "derived_in_archaic"
 informative_site_range: "0"

 null_dataset:
     name: "null"
     # VCF Info
     vcf_file_pattern: "'$data_dir'/null/vcfs/{sample}.mod.vcf.gz"
     chrom_sizes: "'$chromsize'"
     # Population info
     population_file: "'$data_dir'/null/'$mdl'.popfile"
     archaic_populations:
         - "Neand1"
     modern_populations:
         - "ASN"
         - "EUR"

 test_dataset:
     name: "'$mdl'_'$admix'"
     # VCF Info
     vcf_file_pattern: "'$data_dir'/'$admix'/vcfs/{sample}.mod.vcf.gz"
     chrom_sizes: "'$chromsize'"
     # Population info
     population_file: "'$data_dir'/'$admix'/'$mdl'.popfile"
     archaic_populations:
         - "Neand1"
     modern_populations:
         - "ASN"
         - "EUR"
' \
> $configfile
