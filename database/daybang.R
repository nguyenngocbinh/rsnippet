
rm(list = ls())
# Load cac package can thiet
library(DBI)
library(odbc)
library(tictoc)
library(readxl)
library(readr)
library(dplyr)
library(purrr)

# Kiem tra cac ket noi
odbc::odbcListDrivers()

#-------------------------------------------------------------------------------
# Ket noi vao DB
con <- dbConnect(odbc(),
                 Driver = "SQL Server",
                 Server = "VM-DC-JUMPSRV77\\IFRS9", # chu y phai dung 2 dau gach ngang
                 Database = "IFRS9_CUSTOMER",
                 UID = "sa",
                 PWD = "Tpb@123",
                 Port = 1433)

# Kiem tra cac bang da co
dbListTables(con, schema = "sa")

#-------------------------------------------------------------------------------
# Kiem tra danh sach file da co
list_xlsx_files <- Sys.glob("CUSTOMER/*.xlsx") 
list_csv_files <- Sys.glob("CUSTOMER/*.csv") 

# file xlsx
list_xlsx_files %>% 
  as.data.frame() %>% 
  set_names("full_name") %>% 
  mutate (group_name = substr(full_name, 10, nchar(full_name) - 14)) %>% 
  distinct(group_name)

# 1 IFRS9_CUST_CARD_AMT # col_types = c("numeric", "text", "date", rep("numeric", 16))
# 2 IFRS9_CUST_CARD_TXN # col_types = c("date", "text", rep("numeric", 27))
# 3 IFRS9_CUST_CASA_TXN # col_types = c("date", "text", rep("numeric", 36))

# file csv
list_csv_files %>% 
  as.data.frame() %>% 
  set_names("full_name") %>% 
  mutate (group_name = substr(full_name, 10, nchar(full_name) - 13)) %>% 
  distinct(group_name)

# IFRS9_CUST_ACCOUNT_CASA # colClasses = c("Date", 'character', rep("numeric", 32))

#-------------------------------------------------------------------------------
# Day file xlsx
group_push_file <- "IFRS9_CUST_CASA_TXN"
list_push_file <- Sys.glob(paste0("CUSTOMER/",group_push_file, "*"))

f_push_db_xlsx <- function(input_file, sql_tbl_name, input_types){
  tic(paste("total time", input_file))
  tic("time to read file")
  df <- read_excel(input_file, col_types = input_types)
  toc()
  tic("push to DB")
  if (nrow(df) <= 500000){
    dbWriteTable(con, sql_tbl_name , df[1:nrow(df), ], append = TRUE)
  }
  else if (nrow(df) <= 1000000 & nrow(df) > 500000) {
    dbWriteTable(con, sql_tbl_name , df[1:500000, ], append = TRUE)
    dbWriteTable(con, sql_tbl_name , df[500001:nrow(df), ], append = TRUE)
  }
  else if (nrow(df) <= 1500000 & nrow(df) > 1000000) {
    dbWriteTable(con, sql_tbl_name , df[1:500000, ], append = TRUE)
    dbWriteTable(con, sql_tbl_name , df[500001:1000000, ], append = TRUE)
    dbWriteTable(con, sql_tbl_name , df[1000001:nrow(df), ], append = TRUE)
  } else {
    dbWriteTable(con, sql_tbl_name , df[1:500000, ], append = TRUE)
    dbWriteTable(con, sql_tbl_name , df[500001:1000000, ], append = TRUE)
    dbWriteTable(con, sql_tbl_name , df[1000001:1500000, ], append = TRUE)
    dbWriteTable(con, sql_tbl_name , df[1500001:nrow(df), ], append = TRUE)
  }
  toc()
  toc()
}

# Day bang len 
list_push_file %>% 
  map(f_push_db_xlsx, 
      sql_tbl_name = group_push_file, 
      input_types = c("date", "text", rep("numeric", 36)))

#-------------------------------------------------------------------------------
# Day file csv
group_push_file <- "IFRS9_CUST_ACCOUNT_CASA"
list_push_file <- Sys.glob(paste0("CUSTOMER/",group_push_file, "*"))

f_push_db_csv <- function(input_file, sql_tbl_name){
  tic(paste("total time", input_file))
  tic("time to read file")
  df <- data.table::fread(input_file, colClasses = c("Date", 'character', rep("numeric", 32)))
  new_names <- names(df)[2:34]
  df <- df[,1:33]
  names(df) <- new_names
  toc()
  tic("push to DB")
  # Do khong day duoc file qua to nen phai tach ra theo dong
  if (nrow(df) <= 500000){
    dbWriteTable(con, sql_tbl_name , df[1:nrow(df), ], append = TRUE)
  }
  else if (nrow(df) <= 1000000 & nrow(df) > 500000) {
    dbWriteTable(con, sql_tbl_name , df[1:500000, ], append = TRUE)
    dbWriteTable(con, sql_tbl_name , df[500001:nrow(df), ], append = TRUE)
  }
  else if (nrow(df) <= 1500000 & nrow(df) > 1000000) {
    dbWriteTable(con, sql_tbl_name , df[1:500000, ], append = TRUE)
    dbWriteTable(con, sql_tbl_name , df[500001:1000000, ], append = TRUE)
    dbWriteTable(con, sql_tbl_name , df[1000001:nrow(df), ], append = TRUE)
  } else {
    dbWriteTable(con, sql_tbl_name , df[1:500000, ], append = TRUE)
    dbWriteTable(con, sql_tbl_name , df[500001:1000000, ], append = TRUE)
    dbWriteTable(con, sql_tbl_name , df[1000001:1500000, ], append = TRUE)
    dbWriteTable(con, sql_tbl_name , df[1500001:nrow(df), ], append = TRUE)
  }
  
  toc()
  toc()
}

list_push_file %>% 
  map(f_push_db_csv, sql_tbl_name = group_push_file)


