# 	 This file is used to plot figures for the software Bayescan in R.

#    This program, BayeScan, aims at detecting genetics markers under selection,
#	 based on allele frequency differences between population. 
#    Copyright (C) 2010  Matthieu Foll
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Arguments:
# - file is the name of your file ex: "output_fst.txt"
# - the q-value threshold corresponding to the target False Discovery Rate (FDR)
# - size is the size of the points and text labels for outliers
# - pos is the distance between the points and the labels 
# - highlight is a optional list of marker indices to display in red.
# - name_highlighted alows to write the indices of highlighted markers instead of using a point like the other markers
# - add_text adds the indices of the outlier markers

# Output:
# This function returns different paremeters in a list
# - outliers: the list of outliers
# - nb_outliers: the number of outliers

# Typical usage: 
# - load this file into R (file/source R code)
# - in R, go to the directory where "output_fst.txt" is (file/change current dir)
# - at the R prompt, type 
# > plot_bayescan("output_fst.txt",FDR=0.05)
# if you save the output in a variable, you can recall the different results:
# results<-plot_bayescan("output_fst.txt",FDR=0.05)
# results$outliers
# results$nb_outliers

#
# plotting posterior distribution is very easy in R with the output of BayeScan:
# first load the output file *.sel produced by BayeScan
# > mydata=read.table("bi.sel",colClasses="numeric")
# choose the parameter you want to plot by setting for example:
# parameter="Fst1"
# then this line will make the plot for:
# > plot(density(mydata[[parameter]]),xlab=parameter,main=paste(parameter,"posterior distribution"))
# you can plot population specific Fst coefficient by setting
# parameter="Fst1"
# if you have non-codominant data you can plot posterior for Fis coefficients in each population:
# parameter="Fis1"
# if you test for selection, you can plot the posterior for alpha coefficient for selection:
# parameter="alpha1"
# you also have access to the likelihood with:
# parameter="logL"
# if you have the package "boa" installed, you can very easily obtain Highest Probability 
# Density Interval (HPDI) for your parameter of interest (example for the 95% interval):
# > boa.hpd(mydata[[parameter]],0.05)

library(dplyr)

#setting variables
FDR=0.6
Fst_bayescan <- read.table("/Users/maxineliu/work/bufo/outlier_methods/Sniffles/bayescan.dir/output_bayescan/12bufo.DUP.filtered_pr10_fst.txt")
ID_vcf <- read.table("/Users/maxineliu/work/bufo/outlier_methods/Sniffles/bayescan.dir/results_plots/12bufo.DUP.filtered_ID.txt", col.names = c("ID"))
##############

df <- data.frame(ID_vcf, Fst_bayescan)
outlier <- df %>% slice_min(qval, n=1) #return rows with the 100 minimum qvals
# outlier <- df[df$qval <= FDR,]
nrow(outlier) #oulier个数
index_outlier <- as.numeric(rownames(outlier)) #this list could be passed to plot_bayescan function as parameter "highlight"
write(outlier[, 1], file = "/Users/maxineliu/work/bufo/outlier_methods/bayescan.dir/12bufo.DUP.filtered.bayescan.pr10.outlier.id", sep = "\n") # used to extract outlier records from VCF
write.table(arrange(outlier, qval), file = "/Users/maxineliu/work/bufo/outlier_methods/Sniffles/bayescan.dir/results_plots/12bufo.DUP.filtered_pr10_outlier_fst.txt", sep = "\t", eol = "\n", row.names = F, quote = F)
plot_bayescan<-function(res,FDR=0.05,size=1,pos=0.35,highlight=NULL,name_highlighted=F,add_text=T)
{
if (is.character(res))
  res=read.table(res)

colfstat=5
colq=colfstat-2

highlight_rows=which(is.element(as.numeric(row.names(res)),highlight))
non_highlight_rows=setdiff(1:nrow(res),highlight_rows)

outliers=as.integer(row.names(res[res[,colq]<=FDR,]))

ok_outliers=TRUE
if (sum(res[,colq]<=FDR)==0)
	ok_outliers=FALSE;

res[res[,colq]<=0.0001,colq]=0.0001

plot_bayescan# plot

plot(log10(res[,colq]),res[,colfstat],xlim=rev(range(log10(res[,colq]))),xlab="log10(q value)",ylab=names(res[colfstat]),type="n")
points(log10(res[non_highlight_rows,colq]),res[non_highlight_rows,colfstat],pch=19,cex=size)

if (name_highlighted) {
 	if (length(highlight_rows)>0) {
 		text(log10(res[highlight_rows,colq]),res[highlight_rows,colfstat],row.names(res[highlight_rows,]),col="red",cex=size*1.2,font=2)
 	}
}
else {
	points(log10(res[highlight_rows,colq]),res[highlight_rows,colfstat],col="red",pch=19,cex=size)
	# add names of loci over p and vertical line
	if (ok_outliers & add_text) {
		text(log10(res[res[,colq]<=FDR,][,colq])+pos*(round(runif(nrow(res[res[,colq]<=FDR,]),1,2))*2-3),res[res[,colq]<=FDR,][,colfstat],row.names(res[res[,colq]<=FDR,]),cex=size)
	}
}
lines(c(log10(FDR),log10(FDR)),c(-1,1),lwd=2)

return(list("outliers"=outliers,"nb_outliers"=length(outliers)))
}

plot_bayescan("/Users/maxineliu/work/bufo/outlier_methods/bayescan.dir/res_bayescan/12bufo.DUP.filtered_pr10_fst.txt",FDR=0.1,size=1,pos=0.35,highlight=c(1305),name_highlighted=F,add_text=T)
