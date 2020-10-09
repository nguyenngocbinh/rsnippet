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

# Donut chart
```{}
count.data <- data.frame(
  class = c("1st", "2nd", "3rd", "Crew"),
  n = c(325, 285, 706, 885),
  prop = c(14.8, 12.9, 32.1, 40.2)
)
count.data

# Add label position
count.data <- count.data %>%
  arrange(desc(class)) %>%
  mutate(lab.ypos = cumsum(prop) - 0.5*prop)
count.data

mycols <- c("#0073C2FF", "#EFC000FF", "#868686FF", "#CD534CFF")

ggplot(count.data, aes(x = "", y = prop, fill = class)) +
  geom_bar(width = 1, stat = "identity", color = "white") +
  coord_polar("y", start = 0)+
  geom_text(aes(y = lab.ypos, label = prop), color = "white")+
  scale_fill_manual(values = mycols) +
  theme_void()

# Donut chart
ggplot(count.data, aes(x = 2, y = prop, fill = class)) +
  geom_bar(stat = "identity", color = "white") +
  coord_polar(theta = "y", start = 0)+
  geom_text(aes(y = lab.ypos, label = prop), color = "white")+
  scale_fill_manual(values = mycols) +
  theme_void()+
  xlim(0.5, 2.5)
```
