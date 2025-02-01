#!/usr/bin/Rscript
library(lessR)
library(getopt)
library(RColorBrewer)

spec = matrix(c(
 'input_file', 'i', 1, "character",
 'output_file', 'o', 1, "character"
 ), byrow=TRUE, ncol=4
)

opt = getopt(spec)

# read the table
#print (opt$input_file)

short <- read.delim(opt$input_file, sep='\t')

names(short) <- c("species", "perc")

short$old <- short$species

short$species[short$perc<1] <- ' '

short

cols <- brewer.pal(length(unique(short$old)), "Set2")

#cols <- rainbow(length(unique(short$old)))

g = PieChart(species, perc, data=short, fill=cols, main=NULL)

pdf(opt$output_file,width=12,height=12)

print(g)

dev.off()

