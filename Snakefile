# Snakefile to generate max match percent for population

#configfile: "/Genomics/grid/users/abwolf/SimulatedDemographic/MatchPvalue/bin/config_ABC_test.yaml"

null_archaic_pops_str = "_".join(config["null_dataset"]["archaic_populations"])
null_modern_pops_str = "_".join(config["null_dataset"]["modern_populations"])
test_archaic_pops_str = "_".join(config["test_dataset"]["archaic_populations"])
test_modern_pops_str = "_".join(config["test_dataset"]["modern_populations"])

null_database_basename = (config["null_dataset"]["name"] + "-"
    + null_modern_pops_str + "_matchto_" + null_archaic_pops_str + "."
    + config["informative_site_method"]
    + ".windows-" + config["window_size"] + "-" + config["window_step_size"])
null_database_dir = (config["null_dataset"]["directory"] + "/" + null_database_basename)

pvalue_base = (config["test_dataset"]["name"] + "-"
    + test_modern_pops_str + "_matchto_" + test_archaic_pops_str + "."
    + "informative_site_range_" + config["informative_site_range"])


test_sample_files = snakemake.utils.listfiles(
    config["test_dataset"]["directory"] + "/"
    + config["test_dataset"]["vcf_file_pattern"])
test_samples = dict((y[0], x) for x, y in test_sample_files)

rule all:
    input:
        expand(config["test_dataset"]["directory"]
               + "/match_pvalues/" + null_database_basename + "/"
               + "pvalue_table_{sample}_"
               + pvalue_base + ".tsv.gz",
            sample=test_samples.keys())


def get_test_vcf(wildcards):
    return test_samples[wildcards.sample]

# rule match_pct_pvalue:
#     input:
#         expand(null_database_dir + "/match_pvalues/pvalue_table_{sample}_" + pvalue_base + ".tsv",
#            sample=test_samples.keys())
#     output: null_database_dir + "/pvalue_table_" + pvalue_base + ".tsv"
#     run:
#        shell("head -1 {input[0]:q} > {output:q}")
#        for f in input:
#         shell("tail -n +2 {f:q} >> {output:q}")

rule match_pct_pvalue_sample:
    input: vcf=get_test_vcf,
           populations_file=(config["test_dataset"]["directory"] + "/" + config["test_dataset"]["population_file"]),
           match_pct_database=null_database_dir + "/match_percent_database.db",
    #       overlap_regions=(config["test_dataset"]["directory"] + "/" + config["test_dataset"]["regions_bed_combined"])
    output: config["test_dataset"]["directory"] + "/match_pvalues/" + null_database_basename + "/" + "pvalue_table_{sample}_" + pvalue_base + ".tsv.gz"
    params:
        archaic_populations=" ".join(config["test_dataset"]["archaic_populations"]),
        modern_populations=" ".join(config["test_dataset"]["modern_populations"])
    shell:
        'archaic_match max-match-pct '
            '--vcf {input.vcf:q} '
            '--archaic-populations {params.archaic_populations} '
            '--modern-populations {params.modern_populations} '
            '--chrom-sizes {config[test_dataset][chrom_sizes]} '
            '--populations {input.populations_file:q} '
            '--window-size {config[window_size]} '
            '--step-size {config[window_step_size]} '
            '--match-pct-database {input.match_pct_database:q} '
            '--informative-site-method {config[informative_site_method]} '
            '--informative-site-range {config[informative_site_range]} '
            #'--overlap-regions {input.overlap_regions:q} '
            '| bgzip > {output:q}'


# # Combine introgressed regions files
#
# region_files_tuples = snakemake.utils.listfiles(
#     config["test_dataset"]["directory"] + "/"
#     + config["test_dataset"]["regions_bed_pattern"])
# region_files = [x[0] for x in region_files_tuples]
#
# rule combine_introgressed_regions:
#     input:
#         region_files=region_files,
#         sample_haplotype_map=(config["test_dataset"]["directory"] + "/" +
#                               config["test_dataset"]["haplotype_to_sample_map"])
#     output:
#         config["test_dataset"]["directory"] + "/" + config["test_dataset"]["regions_bed_combined"]
#     params:
#         input_glob=config["test_dataset"]["directory"] + "/" + config["test_dataset"]["regions_bed_pattern"].format(id="*")
#     shell:
#         'column_replace '
#             '{params.input_glob:q} '
#             '-d {input.sample_haplotype_map:q} '
#             '-c 4 '
#             '| sort -k 1,1 -k 2,2n '
#             '| bgzip > {output:q}'


# Build Null Database

null_sample_files = snakemake.utils.listfiles(
    config["null_dataset"]["directory"] + "/"
    + config["null_dataset"]["vcf_file_pattern"])
null_samples = dict((y[0], x) for x, y in null_sample_files)

def get_null_vcf(wildcards):
    return null_samples[wildcards.sample]

rule match_pct:
    input:
        vcf=get_null_vcf,
        population_file=(config["null_dataset"]["directory"] + "/" + config["null_dataset"]["population_file"])
    output:
        temp(null_database_dir + "/tmp/{sample}_match_pct_counts.tsv")
    params:
        archaic_populations=" ".join(config["null_dataset"]["archaic_populations"]),
        modern_populations=" ".join(config["null_dataset"]["modern_populations"])
    shell:
        'archaic_match max-match-pct '
            '--vcf {input.vcf:q} '
            '--populations "{input.population_file:q}" '
            '--archaic-populations {params.archaic_populations} '
            '--modern-populations {params.modern_populations} '
            '--chrom-sizes "{config[null_dataset][chrom_sizes]}" '
            '--informative-site-method {config[informative_site_method]} '
            '> {output:q}'

rule build_db:
    input:
        expand(null_database_dir + "/tmp/{sample}_match_pct_counts.tsv",
           sample=null_samples.keys())
    output: null_database_dir + "/match_percent_database.db"
    params: input_glob=null_database_dir + "/tmp/*_match_pct_counts.tsv"
    shell:
        'archaic_match build-db '
        '--match-pct-count {params.input_glob:q} '
        '--db {output:q}'
