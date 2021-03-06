#################################################
## 
## Purpose of script: Parse Probe Miner data dump to be used as target annotation in Open Targets
## Description: Process Probe Miner data dump and generate a tsv file with three columns:
##              HGNC symbol, Uniprot accession and Nr of probes 
##
## Authors: Michaela Spitzer, Asier Gonzalez
## Maintainer: Asier Gonzalez
## Email: "data@opentargets.org
##
## Date Created: Oct 2018
##
## Copyright: Copyright 2014-2019, Open Targets
## License: Apache 2.0
##
#################################################

# Work on directory with input file
working_dir <- file.path("/Users","gonzaleza","opentargets", "19.09")
setwd(working_dir)

# Specify input file
probe_miner_dump <- "probeminer_datadump_2019-07-01.txt"

library("dplyr")
library("tidyr")
library("tibble")

# *** UniProt - HGNC map from Open Targets target file ***
target_id_table <- read.csv("19.09_target_list.csv", header = F, stringsAsFactors = F)
colnames(target_id_table) <- c("ensembl_id","approved_symbol", "uniprot_accessions", "association_counts")
target_id_table <- target_id_table %>% select(approved_symbol, uniprot_accessions) %>% unnest(uniprot_accessions=strsplit(uniprot_accessions, "|", fixed=T))

# *** Load and process the Probe Miner data ***
# Need to add comment.char="" because the smile strings can contain '#' 
probe_miner_dump_df <- read.table(file= probe_miner_dump, header=TRUE, sep="\t", stringsAsFactors=FALSE, comment.char="")

# Pull out target and probe IDs with target_potency_raw > 5 to generate a 'count table'
probe_miner_dump_df <- probe_miner_dump_df %>% filter(target_potency_raw > 5) %>% select(UNIPROT_ACCESSION, COMPOUND_ID)

# Generate the 'count/frequency table'
probe_count_per_target <- probe_miner_dump_df %>% group_by(UNIPROT_ACCESSION) %>% summarise(probes_per_target=n())

# Map provided UniProt IDs to HGNC symbols
probe_count_per_target_with_hgnc <- left_join(probe_count_per_target, target_id_table, by = c("UNIPROT_ACCESSION" = "uniprot_accessions"))

# Get the unmapped IDs
targets_no_hgnc <- probe_count_per_target_with_hgnc %>% filter(is.na(approved_symbol))

# Export unmapped IDs and process CSV file in Google sheet 'ProbeMiner - ID Mapping'
write.csv(targets_no_hgnc, file="ProbeMiner_01_07_2019_targets_no_hgnc.csv", row.names=FALSE)

# Get all targets that have been mapped
targets_with_hgnc <- probe_count_per_target_with_hgnc %>% filter(!is.na(approved_symbol))

# Save table with hgnc_symbol, uniprot_symbol, nr_of_probes for the OT pipeline
write.table(targets_with_hgnc %>% select(approved_symbol, UNIPROT_ACCESSION, probes_per_target), file="chemicalprobes_probeminer-01-07-2019.tsv", sep="\t", row.names=FALSE, col.names = c("hgnc_symbol", "uniprot_symbol", "nr_of_probes"), quote=FALSE) 
### --- End of Probe Miner data dump preprocessing ---


### --------------------------------------------------------------------------------------
### Optional: overlap with targets that have manually curated probes ###
hist(table(D[D[,18]==1,1]), breaks=200, ylim=c(0,50))

# List of proteins that have manually curated chemical probes
OTprobeTargets<-read.table(file="uniprot-yourlist%3AM20180716A7434721E10EE6586998A056CCD0537E9345E6M-filtered-rev--.tab", stringsAsFactors=FALSE, sep="\t", header=TRUE)

setdiff(OTprobeTargets[,3],unique(D[,1]))
# Targets covered by manually curated probes, but not ProbeMiner
setdiff(unique(OTprobeTargets[,3]),unique(D[D[,18]==1,1])) # 143
# Targets covered by ProbeMiner but not by manually curated probes
setdiff(unique(D[D[,18]==1,1]), unique(OTprobeTargets[,3])) # 207


# 50 Uniprot IDs overlap between manually curated chemical probes and Probe Miner sets
intersect(unique(OTprobeTargets[,3]), (unique(D[D[,18]==1,1])))

# Get the number of 'suitable probes' per target
sort(table(suitableProbes[,1]))
### End: optional ###
