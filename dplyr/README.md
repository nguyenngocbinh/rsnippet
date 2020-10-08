# dplyr with bang bang example

```{r}
add_tag_count <- function(x, cname, count_col){
  
  cname <- enquo(cname)
  
  count_col <- enquo(count_col)
  count_col_name <- quo_name(count_col)

  x %>% 
    mutate(!!count_col_name := map_int(!!cname, length))
}
```
