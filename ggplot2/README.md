# Pie chart
Pie chart with other approach this by defining another variable (call pos) in df that calculates the position of text labels. 
```{r}
# https://stackoverflow.com/questions/24803460/r-ggplot2-add-labels-on-facet-pie-chart
library(dplyr)
library(ggplot2)

df <- df %>% group_by(year) %>% mutate(pos = cumsum(quantity)- quantity/2)

ggplot(data=df, aes(x=factor(1), y=quantity, fill=factor(prod))) +
  geom_bar(stat="identity") +
  geom_text(aes(x= factor(1), y=pos, label = quantity), size=10) +  # note y = pos
  facet_grid(facets = .~year, labeller = label_value) +
  coord_polar(theta = "y")
```
