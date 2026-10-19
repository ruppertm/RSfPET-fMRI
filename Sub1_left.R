#fPET dbs Sub1 left VTAs

#adapt for each subject 
setwd("~/Documents/fPET-fMRI-DBS/SCAN_analysis/Sub1")

library(clinfun)
library(circlize)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(scales)

#import data 
dbs_fSCAN<-read.csv("roi_values_marsbar.csv", header = TRUE)

#add time
dbs_fSCAN$time<-1:30

#plot timecourse for all ROIs
for (i in 2:50){
  col_i<-colnames(dbs_fSCAN)[i]
                 
  p<-ggplot(dbs_fSCAN, aes (x=time, y=.data[[col_i]]))+
    geom_line()+
    theme_bw()+
    labs(x="Time (Min)", y=expression("Relative ["^18*"F]FDG Uptake"))+
theme(
  legend.position=c(0.1,0.85),
  legend.title=element_blank(),
  text=element_text(size=20),
  axis.text.x=element_text(size=18),
  axis.texty=element_text(size=18)
)
print(p)
ggsave(filename=paste0("dbs_fSCAN_", col_i, ".png"), plot=p,
       width=8, height=5,dpi=300)
}



#separate col vectors for all VTAs and SCAN ROIs and sphere
VTAs<-colnames(dbs_fSCAN[,2:35])
ROIs<-colnames(dbs_fSCAN[,37:50])
sphere<-"RSfPET001_sphere_510_2_74"

#for all VTAs + peak  (connectome ring)
Corr<-cor(dbs_fSCAN[,VTAs],dbs_fSCAN[,sphere], use="pairwise.complete.obs")  

#define edges for connectome with from/to
edges<-as.data.frame(Corr) |>
rownames_to_column("from") |>
pivot_longer(-from, names_to="to", values_to="r") 

#define colors for r colorbar
col_fun<-colorRamp2(
    c(-1,0, 1),
    c("#005083","grey","#ffe4a8")
  )


#assign colors and line width to edges
edges<-edges |>
mutate(
  col=col_fun(r),
  lwd=rescale(r,t=c(1,6))
)

#add group var for categories
edges_g<- edges%>%
  mutate(
    group=case_when(
      startsWith(from, "x0_20") ~"0-20",
      startsWith(from, "x20_40")~"20-40",
      startsWith(from, "x40_60")~"40-60",
      startsWith(from,"x60_80")~"60-80",
      startsWith(from,"x80_100")~"80-100",
      TRUE~NA_character_
    )
  )

group_cols<-c(
  "0-20"="#005083",
  "20-40"="#0064ab",
  "40-60"="#6876a4",
  "60-80"="#d9a030",
  "80-100"="#ffe4a8"
  )


#define sectors for connectome
from_cols<- edges_g%>%
  distinct(from, group)%>%
  mutate(col=group_cols[as.character(group)])%>%
  select(from, col)%>%
  deframe()

to_cols<-setNames(
  rep("grey80", length(unique(edges_g$to))),
  unique(edges_g$to)
)

    
grid.col<- c(from_cols,to_cols)

  
ragg::agg_png(
  filename="Connectome_Sub1.png",
  width=10, height=8,
  units="in",
  res=300,
  background="white"
)


circos.clear()

chordDiagram(
  x=edges[,c("from","to","r")],
  grid.col=grid.col,
  col=edges$col,
  transparency =0.2,
  link.lwd=edges$lwd,
  annotationTrack =c( "grid"),
  preAllocateTracks=1
)

text(
  x=0.0,
  y=-0.9,
  labels="VTAs",
  family="Arial",
  font=1,
  cex=4
)

text(
  x=0,
  y=0.9,
  labels="Peak",
  family="Arial",
  srt=0,
  font=1,
  cex=4
)


#colobar

fields::image.plot(
  legend.only=TRUE,
  zlim=c(-1,1),
  col= col_fun(seq(-1,1, length.out=100)),
  smallplot=c(0.87, 0.89, 0.30,0.70),
  legend.width=1.5,
  legend.shrink=0.8,
  axis.args=list(at=c(-1, -0.5,0,0.5,1),
                 cex.axis=2),
  legend.args=list(
    text="Metabolic \n Connectivity (r)",
    side=1,
    line=-20,
    cex=3
  )
)


dev.off()

#mean MC analysis on subject level

#for peak sphere 
Corr<-cor(dbs_fSCAN[,VTAs],dbs_fSCAN[,sphere], use="pairwise.complete.obs")  

edges<-as.data.frame(Corr) |>
  rownames_to_column("from") |>
  pivot_longer(-from, names_to="to", values_to="r") 

region_groups<-tibble(
  region= c("RSfPET001_sphere_510_2_74", colnames(dbs_fSCAN[,2:35])),
  group=c("peak", rep("0-20",15), rep("20-40",7), rep("40-60",4), rep("60-80",5), rep("80-100",3))
)

edges_g <- edges %>%
  left_join(region_groups, by=c("from"="region"))
PEAKedges_g_Sub1L<-edges_g

edges_group_mean <- edges_g %>%
  group_by (group,from) %>%
  summarise(
    mean_r =mean(r, na.rm=TRUE),
 .groups="drop"
  )


ggplot(edges_group_mean,
       aes(x=group, y=mean_r,fill=group))+
  

  
  geom_jitter(aes(colour=group),
    position=position_jitter(
      width=0.06,
      height=0),
    shape=21,
    stroke=0.4,
    size=2.5,
    alpha=0.6,
    colour="black")+
  
  #median
  stat_summary(
    fun=median,
    geom= "crossbar",
    width=0.20,
    colour="black",
    linewidth=0.4)+
  
  
  stat_summary(
    fun=median,
    geom="crossbar",
    width=0.06,
    linewidth=0.7)+

scale_fill_manual(values=c("#005083","#0064ab","#6876a4","#d9a030","#ffe4a8"))+
  theme_classic(base_size=12)+
  theme(legend.position="none")+
  labs(x="VTA group",
       y="Metabolic Connectivity\n to peak ROI (r)",
       fill="r")+
  theme(
    axis.title.x=element_text(size=20),
    axis.title.y = element_text(size=20),
    axis.text.x = element_text(size=20),
    axis.text.y = element_text(size=20)
  )+
  annotate(
    "text",
    x=-Inf,
    y=Inf,
    label="'JT = 320'  ~~ italic(P) < 0.001",
    parse=TRUE,
    hjust=-0.1,
    vjust=1.2,
    size=6)

fig_width<- 6
fig_height<- 4
ggsave("MC_peak.png", width=fig_width, height=fig_height, dpi=300)

#test on subject level
#Jonckheere-terpstra test 

edges_g$group<-factor(edges_g$group, ordered=TRUE)

jonckheere.test(
  x=edges_g$r,
  g=edges_g$group,
  alternative="increasing"
)

#for SCAN ROIs

#for all VTAs + SCAN
Corr<-cor(dbs_fSCAN[,VTAs],dbs_fSCAN[,ROIs], use="pairwise.complete.obs")  

#define edgs
edges<-as.data.frame(Corr) |>
  rownames_to_column("from") |>
  pivot_longer(-from, names_to="to", values_to="r") 


#assign color and width to edges
col_fun<-colorRamp2(
  c(-1,0, 1),
  c("#005083","grey","#ffe4a8")
)

edges<-edges |>
  mutate(
    col=col_fun(r),
    lwd=rescale(r,t=c(1,6))
  )

#add group var for categories
edges_g<- edges%>%
  mutate(
    group=case_when(
      startsWith(from, "x0_20") ~"0-20",
      startsWith(from, "x20_40")~"20-40",
      startsWith(from, "x40_60")~"40-60",
      startsWith(from,"x60_80")~"60-80",
      startsWith(from,"x80_100")~"80-100",
      TRUE~NA_character_
    )
  )

group_cols<-c(
  "0-20"="#005083",
  "20-40"="#0064ab",
  "40-60"="#6876a4",
  "60-80"="#d9a030",
  "80-100"="#ffe4a8"
)


#define sectors for connectome
from_cols<- edges_g%>%
  distinct(from, group)%>%
  mutate(col=group_cols[as.character(group)])%>%
  select(from, col)%>%
  deframe()

to_cols<-setNames(
  rep("grey80", length(unique(edges_g$to))),
  unique(edges_g$to)
)


grid.col<- c(from_cols,to_cols)


ragg::agg_png(
  filename="Connectome_Sub1SCAN.png",
  width=10, height=8,
  units="in",
  res=300,
  background="white"
)


circos.clear()

chordDiagram(
  x=edges[,c("from","to","r")],
  grid.col=grid.col,
  col=edges$col,
  transparency =0.2,
  link.lwd=edges$lwd,
  annotationTrack =c( "grid"),
  preAllocateTracks=1
)

text(
  x=0.0,
  y=-0.9,
  labels="VTAs",
  family="Arial",
  font=1,
  cex=4
)

text(
  x=0,
  y=0.9,
  labels="SCAN",
  family="Arial",
  srt=0,
  font=1,
  cex=4
)


#colobar

fields::image.plot(
  legend.only=TRUE,
  zlim=c(-1,1),
  col= col_fun(seq(-1,1, length.out=100)),
  smallplot=c(0.87, 0.89, 0.30,0.70),
  legend.width=1.5,
  legend.shrink=0.8,
  axis.args=list(at=c(-1, -0.5,0,0.5,1),
                 cex.axis=2),
  legend.args=list(
    text="Metabolic \n Connectivity (r)",
    side=1,
    line=-20,
    cex=3
  )
)


dev.off()

#repeat corr analysis with SCAN ROIs only 
Corr<-cor(dbs_fSCAN[,VTAs],dbs_fSCAN[,ROIs], use="pairwise.complete.obs")  

edges<-as.data.frame(Corr) |>
  rownames_to_column("from") |>
  pivot_longer(-from, names_to="to", values_to="r") 

edges_g<- edges_g%>%
  mutate(
    group=case_when(
      startsWith(from, "x0_20") ~"0-20",
      startsWith(from, "x20_40")~"20-40",
      startsWith(from, "x40_60")~"40-60",
      startsWith(from,"x60_80")~"60-80",
      startsWith(from,"x80_100")~"80-100",
      TRUE~NA_character_
    )
  )

edges_g <- edges %>%
  left_join(region_groups, by=c("from"="region"))

SCANedges_g_Sub1L<-edges_g

edges_group_mean <- edges_g %>%
  group_by (group,from) %>%
  summarise(
    mean_r =mean(r, na.rm=TRUE),
    .groups="drop"
  )


ggplot(edges_group_mean,
       aes(x=group, y=mean_r,fill=group))+

  
  geom_jitter(aes(colour=group),
              position=position_jitter(
                width=0.06,
                height=0),
              shape=21,
              stroke=0.4,
              size=2.5,
              alpha=0.8,
              colour="black")+
  
  #median
  stat_summary(
    fun=median,
    geom= "crossbar",
    width=0.20,
    colour="black",
    linewidth=0.4)+
  
  
  stat_summary(
    fun=median,
    geom="crossbar",
    width=0.06,
    linewidth=0.7)+
  
  scale_fill_manual(values=c("#005083","#0064ab","#6876a4","#d9a030","#ffe4a8"))+
  theme_classic(base_size=12)+
  theme(legend.position="none")+
  labs(x="VTA group",
       y="Metabolic Connectivity\n to SCAN ROI (r)",
       fill="r")+
  theme(
    axis.title.x=element_text(size=20),
    axis.title.y = element_text(size=20),
    axis.text.x = element_text(size=20),
    axis.text.y = element_text(size=20)
  )+
  annotate(
    "text",
    x=-Inf,
    y=Inf,
    label= "'JT = 40477'  ~~ italic(P) == 0.57",
    parse=TRUE,
    hjust=-0.1,
    vjust=1.2,
    size=6)

fig_width<- 6
fig_height<- 4
ggsave("MC_SCAN.png", width=fig_width, height=fig_height, dpi=300)



#test on subject level
#Jonckheere-terpstra test 

edges_g$group<-factor(edges_g$group, ordered=TRUE)

jonckheere.test(
  x=edges_g$r,
  g=edges_g$group,
  alternative="increasing"
)

