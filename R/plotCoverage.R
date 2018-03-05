require(ggplot2)
require(cowplot) # imports save_plot
require(svglite)

rm(list = ls())

cueStats.R1 = read.csv('./output/cueStats.SWOW-EN.R1.csv')
cueStats.R123 = read.csv('./output/cueStats.SWOW-EN.R123.csv')

mR1   = median(cueStats.R1$coverage)
mR123 = median(cueStats.R123$coverage)

# Basic statistics
message('Coverage R1 Mean: ',round(mean(cueStats.R1$coverage)), ' Median: ', round(mR1))
message('Coverage R123 Mean: ',round(mean(cueStats.R123$coverage)), ' Median: ', round(mR123))

p.R1 = ggplot(data=cueStats.R1,aes(cueStats.R1$coverage)) +
      geom_histogram(aes(y = ..count.. / sum(..count..)),col="white",alpha=0.4) +
      geom_vline(data = cueStats.R1, aes(xintercept=round(median(coverage)),colour='black'),linetype='solid',size=1) +
      labs(x="Response coverage R1 (%)", y="Proportion") +
      ylim(0,0.2) +
      scale_x_continuous(breaks=round(c(40,60,80,mR1,100)),limits = c(40,100)) +
      theme(legend.position="none")

p.R123 = ggplot(data=cueStats.R123,aes(cueStats.R123$coverage)) +
  geom_histogram(aes(y = ..count.. / sum(..count..)),col="white",alpha=0.4) +
  geom_vline(data = cueStats.R123, aes(xintercept=round(median(coverage)),colour='black'),linetype='solid',size=1) +
  labs(x="Response coverage R123 (%)", y="Proportion") +
  ylim(0,0.2) +
  scale_x_continuous(breaks=round(c(40,60,80,mR123,100)),limits = c(40,100)) +
  theme(legend.position="none")


p = plot_grid(p.R1, p.R123, labels = c("A", "B"))
save_plot('./figures/responseCoverage.pdf',p, base_height = 4, base_width = 10)
save_plot('./figures/responseCoverage.svg',p, base_height = 4, base_width = 10)
