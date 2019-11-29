# Initial
```{r}
install.packages("spAddins")
install.packages("remedy")
```

# Useful website

[rweekly](https://rweekly.org/)

[awesome-r](https://awesome-r.com/index.html)

[r-users_job](https://www.r-users.com/)

# ggplot

## add hrbrtheme

  - scale_y_comma()
  - theme_ipsum_rc() 

## format axis

- scale_y_continuous(label=scales::comma)
- scale_x_date(date_breaks = "2 month", date_labels = "%m-%Y")
- theme(legend.title = element_blank(),
        legend.position = "bottom",
        axis.text.x = element_text(angle = 30))

## format axis text


```{r}
theme(axis.text.x = element_text(size = 14), axis.title.x = element_text(size = 16),
      axis.text.y = element_text(size = 14), axis.title.y = element_text(size = 16),
      plot.title = element_text(size = 20, face = "bold", color = "darkgreen"))
      
theme(axis.ticks.length.y = unit(nc * 0.15,"cm"))
```



## vietnamese font

```{r}
plot(1:4,rep(1,4), pch=c("\u0111","\u01B0","\u01A1","\u0103"),cex=4)
# Uppercase
plot(1:4,rep(1,4), pch=c("\U0110","\u01AF","\u01A0","\u0102"),cex=4)
```

# data.table

## select 

```{r}
dt[dayid >= ymd(20190827),
   .(trung_binh = mean(amount_thousand),
     trung_vi = median(amount_thousand)),
   by = .(bi_card_group, age_grp)]
```




## ~ mutate 

```{r}
dt <-
  dt[, agr_grp := case_when(age <= 24 ~ "under 24",
                            age <= 29 ~ "24-29",
                            age <= 34 ~ "30-34",
                            age <= 39 ~ "35-39",
                            TRUE ~ "40 +")]
```

```{r}
DT[, `:=`(colA = valA, # valA is assigned to colA
          colB = valB # valB is assigned to colB
          )]
```


## ~ summarise

```{r}
dt_by_month <- dt[, .(amount_thousand = sum(amount_thousand),
                      cnt = .N), by = .(report_month, card_id)]
```


## delete columns

```{r}
flights[, c("delay") := NULL]
flights[, c("speed", "max_speed", "max_dep_delay", "max_arr_delay") := NULL]
```


## Max multiple columns and group by 1 column

```{r}
in_cols  = c("dep_delay", "arr_delay")
out_cols = c("max_dep_delay", "max_arr_delay")
flights[, c(out_cols) := lapply(.SD, max), by = month, .SDcols = in_cols]
```

## Note

```{r}
## did not have to assign the result back to dt
dt[mpg == 19.7,][, mpg := 0]
```

## sort

```{r}
ans <- flights[order(origin, -dest)]
```


## Select columns named in a variable using the .. prefix

```{r}
select_cols = c("arr_delay", "dep_delay")
flights[ , ..select_cols]
```


## returns all columns except arr_delay and dep_delay

```{r}
ans <- flights[, !c("arr_delay", "dep_delay")]
### or
ans <- flights[, -c("arr_delay", "dep_delay")]
```


## .SD: It stands for Subset of Data

## .SDcols: specify just the columns we would like to compute

```{r}
flights[carrier == "AA",                       ## Only on trips with carrier "AA"
        lapply(.SD, mean),                     ## compute the mean
        by = .(origin, dest, month),           ## for every 'origin,dest,month'
        .SDcols = c("arr_delay", "dep_delay")] ## for just those specified in .SDcols
```


## Subset .SD for each group:

```{r}
ans <- flights[, head(.SD, 2), by = month]
```


## setkey

```{r}
setkeyv(flights, "origin") # useful to program with
setkey(flights, origin)

setkeyv(flights, c("origin", "dest")) # provide a character vector of column names
setkey(flights, origin, dest)

key(flights)
```


# dplyr

```{r}
group_by(xxx) %>% summarise(cnt = n())
```

```{r}
category <- enquo(category)	
p <- df %>% 
	group_by(!!category) %>% 
	summarise(cnt = n())

rlang::quo_text(cat)
```
## top_n_by function
```{r}
f_top_n <- function(df, n, top_by){
  top_by <- enquo(top_by)
  
  top_val <- df %>% 
    filter(is.finite(!!top_by)) %>% 
    pull(!!top_by) %>% 
    unique() %>% 
    sort(decreasing = TRUE) %>% 
    head(n) 
  
  filter(df, !!top_by %in% top_val) %>% return()
}

```

# lubridate

```{r}
x <- as.Date("2009-09-02")
wday(ymd(080101), label = TRUE, abbr = TRUE)
month(x)
year(x)
```


# zoo

```{r}
zoo::as.yearmon("Mar 2012", "%b %Y")
```


# file and folder

```{r}
r18_2017 <- Sys.glob(paste0(my_folder, "2017/*.xlsx"))

r18_2017 <- list.files(paste0(my_folder, "2017/"), full.names = T)

dt <- rio::import_list(r18_files, rbind = TRUE)
```


# string

## Bỏ dấu

```{r}
stringi::stri_trans_general('Nguyễn Ngọc Bình', "latin-ascii" )
```


# check slow code by **provis**

```{r}
## Generate data
times <- 4e5
cols <- 150
data <- as.data.frame(x = matrix(rnorm(times * cols, mean = 5), ncol = cols))
data <- cbind(id = paste0("g", seq_len(times)), data)

profvis::profvis({
  data1 <- data   # Store in another variable for this run

  ### Get column means
  means <- apply(data1[, names(data1) != "id"], 2, mean)

  ### Subtract mean from each column
  for (i in seq_along(means)) {
    data1[, names(data1) != "id"][, i] <- data1[, names(data1) != "id"][, i] - means[i]
  }
})
```


# purrr

## compose

```{r}
tidy_lm <- compose(tidy, lm)
tidy_lm(Sepal.Length ~ Species, data = iris)
```


## partial

```{r}
mean_na_rm <- partial(mean, na.rm = TRUE)
```

## reduce

```{r}
dfs <- list(
  age = tibble(name = "John", age = 30),
  sex = tibble(name = c("John", "Mary"), sex = c("M", "F")),
  trt = tibble(name = "Mary", treatment = "A")
)

dfs %>% reduce(full_join)
```

# Hàm xử lý outlier
```{r}
f_outlier <- function(x){
  threshold <- quantile(x, probs = c(0.005, 0.95), na.rm = TRUE, type = 3)
  
  y <- case_when(x > threshold[2] ~ threshold[2],
          x < threshold[1] ~ threshold[1],
          TRUE ~ x) 
  return(y)
}
```
# So sánh khác biệt giữa 2 file
```{r}
library(diffr)
diffr("D:/TMP/new 1.txt", "D:/TMP/new 2.txt", contextSize = 0, minJumpSize = 500)
```

# Optical Character Recognition (OCR)
```{r}
if(!require("tesseract")) {install.packages("tesseract")}
library(tesseract)
library(dplyr)
text <- ocr("D:/tmp/image2.png", engine = tesseract("eng"))
cat(text)
text %>% strsplit(split = "\n") %>% rio::export("x.xlsx")
```
