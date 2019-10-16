# rsnippet
#=============================================================================
# ggplot
#=============================================================================
# ------------------------------------------------------------------

scale_y_continuous(label=scales::comma)+
  scale_x_date(date_breaks = "2 month",
               date_labels = "%m-%Y")+
  theme(legend.title = element_blank(),
        legend.position = "bottom",
        axis.text.x = element_text(angle = 30))

# ------------------------------------------------------------------
# hrbrtheme

ggplot(aes(x = cnt))+
  geom_histogram(bins = 18)+ # bins = 24
  labs(title = "Tong thoi gian",
       subtitle = "don vi",
       x = "So luong",
       y = "So quan sat")+
  scale_y_comma()+
  theme_ipsum_rc()+
  facet_wrap(~ bi_card_group, nrow = 2)

# ------------------------------------------------------------------
theme(axis.text.x = element_text(size = 14), axis.title.x = element_text(size = 16),
      axis.text.y = element_text(size = 14), axis.title.y = element_text(size = 16),
      plot.title = element_text(size = 20, face = "bold", color = "darkgreen"))

# ------------------------------------------------------------------
plot(1:4,rep(1,4),pch=c("\u0111","\u01B0","\u01A1","\u0103"),cex=4)
#=============================================================================
# data.table
#=============================================================================

dt[dayid >= ymd(20190827),
   .(trung_binh = mean(amount_thousand),
     trung_vi = median(amount_thousand)),
   by = .(bi_card_group, age_grp)]

# ------------------------------------------------------------------
dt <-
  dt[, agr_grp := case_when(age <= 24 ~ "under 24",
                            age <= 29 ~ "24-29",
                            age <= 34 ~ "30-34",
                            age <= 39 ~ "35-39",
                            TRUE ~ "40 +")]
# ------------------------------------------------------------------
dt_by_month <- dt[, .(amount_thousand = sum(amount_thousand),
                      cnt = .N), by = .(report_month, card_id)]

# delete columns

flights[, c("delay") := NULL]
flights[, c("speed", "max_speed", "max_dep_delay", "max_arr_delay") := NULL]

# add columns

DT[, `:=`(colA = valA, # valA is assigned to colA
          colB = valB, # valB is assigned to colB
          ...
)]

# Max multiple columns and by 1 column

in_cols  = c("dep_delay", "arr_delay")
out_cols = c("max_dep_delay", "max_arr_delay")
flights[, c(out_cols) := lapply(.SD, max), by = month, .SDcols = in_cols]

# did not have to assign the result back to dt
dt[mpg == 19.7,][, mpg := 0]

# sort
ans <- flights[order(origin, -dest)]

# Select columns named in a variable using the .. prefix
select_cols = c("arr_delay", "dep_delay")
flights[ , ..select_cols]
# returns all columns except arr_delay and dep_delay
ans <- flights[, !c("arr_delay", "dep_delay")]
# or
ans <- flights[, -c("arr_delay", "dep_delay")]

# .SD. It stands for Subset of Data

# .SDcols: specify just the columns we would like to compute
flights[carrier == "AA",                       ## Only on trips with carrier "AA"
        lapply(.SD, mean),                     ## compute the mean
        by = .(origin, dest, month),           ## for every 'origin,dest,month'
        .SDcols = c("arr_delay", "dep_delay")] ## for just those specified in .SDcols

# Subset .SD for each group:

ans <- flights[, head(.SD, 2), by = month]

# setkeyv(flights, "origin") # useful to program with
setkey(flights, origin)


# setkeyv(flights, c("origin", "dest")) # provide a character vector of column names
setkey(flights, origin, dest)

key(flights)

#=============================================================================
# dplyr
#=============================================================================

group_by(xxx) %>%
summarise(cnt = n())


#=============================================================================
# lubridate
#=============================================================================

x <- as.Date("2009-09-02")
wday(ymd(080101), label = TRUE, abbr = TRUE)
month(x)
year(x)

# zoo
zoo::as.yearmon("Mar 2012", "%b %Y")

#=============================================================================
# file and folder
#=============================================================================
r18_2017 <- Sys.glob(paste0(my_folder, "2017/*.xlsx"))

r18_2017 <- list.files(paste0(my_folder, "2017/"), full.names = T)

dt <- rio::import_list(r18_files, rbind = TRUE)

#=============================================================================
# string
#=============================================================================

# Bỏ dấu
stringi::stri_trans_general('Nguyễn Ngọc Bình', "latin-ascii" )


#=============================================================================
# provis
#=============================================================================

# Generate data
times <- 4e5
cols <- 150
data <- as.data.frame(x = matrix(rnorm(times * cols, mean = 5), ncol = cols))
data <- cbind(id = paste0("g", seq_len(times)), data)

profvis::profvis({
  data1 <- data   # Store in another variable for this run

  # Get column means
  means <- apply(data1[, names(data1) != "id"], 2, mean)

  # Subtract mean from each column
  for (i in seq_along(means)) {
    data1[, names(data1) != "id"][, i] <- data1[, names(data1) != "id"][, i] - means[i]
  }
})

#=============================================================================
# purrr
#=============================================================================

tidy_lm <- compose(tidy, lm)
tidy_lm(Sepal.Length ~ Species, data = iris)

# ------------------------------------------------------
mean_na_rm <- partial(mean, na.rm = TRUE)

# ------------------------------------------------------
dfs <- list(
  age = tibble(name = "John", age = 30),
  sex = tibble(name = c("John", "Mary"), sex = c("M", "F")),
  trt = tibble(name = "Mary", treatment = "A")
)

dfs %>% reduce(full_join)
