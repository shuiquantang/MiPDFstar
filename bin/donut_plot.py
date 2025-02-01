#!usr/bin/python3
import argparse
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

# python donut_plot.py -i inputs/domain.tsv -o domain_plot.svg -t "Bactera vs Fungi" -s 1

parser=argparse.ArgumentParser(
      description="This script uses python3. Please make sure you have the correct version installed. This script is used to generate the final MiDOG report.")

parser.add_argument('-i','--input', help='Input abundance file for donut plot',required=True)
parser.add_argument('-t','--title', help='output figure file for donut plot',required=True)
parser.add_argument('-o','--output', help='output figure file for donut plot',required=True)
parser.add_argument('-s','--sorted', help='output figure file for donut plot',required=True)

args = parser.parse_args()
figure_title = args.title
sort_by = args.sorted


def is_file_not_empty(file_path):
      """ Check if file is empty by confirming if its size is 0 bytes"""
      # Check if file exist and it is empty
      return os.path.exists(file_path) and os.stat(file_path).st_size > 0



def donut_plot(df, title, sort_by):
	labels=[]
	sample_df=df
	if sort_by == '0':
		sample_df=sample_df.sort_values(by='species_name', ascending=True)
		for index,row in sample_df.iterrows():
			perc=round(row['RelativeAbundance'], 1);
			label="%s (%s%%)"%(row['species_name'], perc)
			labels.append(label)

	else:
		sample_df=sample_df.sort_values(by='RelativeAbundance', ascending=False)
		for index,row in sample_df.iterrows():
			if row['RelativeAbundance'] >10.0:
				perc=round(row['RelativeAbundance'], 1);
				label="%s (%s%%)"%(row['species_name'], perc)
				labels.append(label)
			else:
				labels.append('')

	for i in range(0,len(labels)):
		if labels[i]!='':
			tmp = labels[i].split(' ')
			if(len(tmp)>1):
			      if ("-" in tmp[1]):
			            tmp[1]='sp.'
			if len(tmp)==3 and len(tmp[1])<5:
			      labels[i]="%s\n%s %s"%(tmp[0],tmp[1],tmp[2])
			else:
			      labels[i]="\n".join(tmp)
	fig, ax = plt.subplots(subplot_kw=dict(aspect="equal"))
	wedges, texts = ax.pie(sample_df['RelativeAbundance'], wedgeprops=dict(width=0.5), startangle=-40)
	for w in wedges:
		w.set_linewidth(0)
	bbox_props = dict(boxstyle="square,pad=0.0", fc="w", ec="k", lw=0.0)
	kw = dict(xycoords='data', textcoords='data', arrowprops=dict(arrowstyle="-"),
		bbox=bbox_props, zorder=0, va="center")
	for i, p in enumerate(wedges):
		ang = (p.theta2 - p.theta1)/2. + p.theta1
		y = np.sin(np.deg2rad(ang))
		x = np.cos(np.deg2rad(ang))
		horizontalalignment = {-1: "right", 1: "left"}[int(np.sign(x))]
		connectionstyle = "angle,angleA=0,angleB={}".format(ang)
		kw["arrowprops"].update({"connectionstyle": connectionstyle})
		if labels[i]!="":
			ax.annotate(labels[i], xy=(x, y), xytext=(1.1*np.sign(x), 0.9*y),horizontalalignment=horizontalalignment, **kw, size=15, style='italic')
	ax.set_xlabel(figure_title, fontsize=17, fontweight='bold')
	sum= round(sample_df['RelativeAbundance'].sum(), 2)
	return(fig)

if is_file_not_empty(args.input):
      sp_perc = pd.read_csv(args.input, sep='\t', header=None)
      sp_perc.columns = ['species_name', 'RelativeAbundance']
      bac_plt = donut_plot(sp_perc, figure_title, sort_by)
      bac_plt.savefig(args.output, dpi=200, bbox_inches='tight',  pad_inches=0.01, format="png")
