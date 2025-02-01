library(dplyr)
library(vegan)
library(ape)
library(ggplot2)
library(data.table)
library(ggrepel)
#library(svglite)

#usage Rscript get_analysis_img.R #input_data #sample_name #sampletype

ggnice<-function()
{
        theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line.x=element_line(color="black"), axis.line.y=element_line(color="black"), axis.text = element_text(color="black"))
}

number_ticks <- function(n) {function(limits) pretty(limits, n)}

args <- commandArgs(trailingOnly = TRUE)

data<-fread(args[1])
data<-data.frame(data)
#data<-data[,-1]
names(data)[1]<-paste0('id')
#print(data)


#print(type)
ref<-fread(args[3])

names(ref)[1]<-paste0('id')
ref_mat<-as.matrix(ref[,-1])
rownames(ref_mat)<-ref$id

#print(ref)

name<-args[2]

sample <- data[, c(1, which(colnames(data) == name))]

#sample<-sample[-1,]
names(sample)[2]<-'Your.sample'
sample<-data.table(sample)
#sample$Your.sample<-round(sample$Your.sample*100,2)


#alpha_div<-diversity(t(ref_mat), "shannon")
alpha_div<-specnumber(t(ref_mat))
alpha_div<-data.frame(alpha_div)

n=max(alpha_div$alpha_div)
m=min(alpha_div$alpha_div)
samp_mat<-as.matrix(sample[,-1])
rownames(samp_mat)<-sample$id


#samp_alpha<-diversity(t(samp_mat), "shannon")
samp_alpha<-specnumber(t(samp_mat))
samp_alpha<-data.frame(samp_alpha)


x_limits=c(1.3,NA)

img<-ggplot(alpha_div, aes(x=' ', y=alpha_div))+
  geom_boxplot(ymin=0, ymax=7,lower=quantile(alpha_div$alpha_div,0.05),middle=quantile(alpha_div$alpha_div,0.05),
                   upper=quantile(alpha_div$alpha_div, 0.95), width=0.6,
               fill='#808080', color='black') +
  geom_text( aes(y=quantile(alpha_div,0.60),
                 label='Clinically healthy
  dogs fall in this range'), check_overlap = TRUE, size=3, fontface = "bold", vjust = 1.5) +
  geom_label_repel(data=samp_alpha, aes(y=samp_alpha, label='Your Sample'),
                   fontface = "bold", color='blue',
                   arrow = arrow(length = unit(0.05, "npc")), xlim=x_limits)+
 coord_flip() + labs(x='', y='') + scale_y_continuous(breaks=number_ticks(11)) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), panel.background = element_blank(), plot.margin=margin(0,0.8,0, 0, "cm"),  axis.line.x = element_line(color='black')) + 
   geom_vline(xintercept=c(1,2.5))

#writeLines(note, './alphaO.txt')
ggsave(args[4], width = 30, height = 6, unit = "cm")

