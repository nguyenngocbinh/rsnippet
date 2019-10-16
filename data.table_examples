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
