rm(list = ls())
library(DBI)
con <- DBI::dbConnect(odbc::odbc(),
                      Driver   = "SQL Server",
                      Server   = "10.9.12.76",
                      Database = "CreditRating",
                      UID      = "SB_BI",
                      PWD      = rstudioapi::askForPassword("Database password"),                     
                      Port     = 1433)
library(dbplyr)

dbListTables(con, Database = "CreditRating") 

#-----------------------------------------------------------------------------
# LAY DU LIEU CUSTOMER FINANCIAL
tlb_Customer <- tbl(con, "tlb_Customer")
tlb_Factor <- tbl(con, "tlb_Factor")
tlb_CustomerFactor <- tbl(con, "tlb_CustomerFactor")
tlb_CompanyScale <- tbl(con, "tlb_CompanyScale")


tlb_Customer %>% colnames()
colnames(tlb_CustomerFactor)
colnames(tlb_Factor)

#-----------------------------------------------------------------------------
# Lay cac chi tieu 
# Nhom chi tieu lon
higher_level_indicator <- tlb_CustomerFactor %>% 
  inner_join(tlb_Factor, by = c("FactorID" = "ID")) %>% 
  filter(ParentCode %in% c('I', 'II')) %>% 
  select(CustomerID, ParentCode, Code, Name)

# Lay gia tri tung chi tieu tai chinh nho
mtc <- tlb_CustomerFactor %>% 
  inner_join(tlb_Factor, by = c("FactorID" = "ID")) %>% 
  filter(IsFinancial == '1', ParentCode %in% c('100', '200', '300', '400', '500')) %>% 
  select(CustomerID, ParentCode, Code, Name, Value, Point, Percentage, IsFinancial, AuthoriseDate.x)

# Lay gia tri tung chi tieu phi tai chinh nho
mptc <- tlb_CustomerFactor %>% 
  inner_join(tlb_Factor, by = c("FactorID" = "ID")) %>% 
  filter(IsFinancial == '0', ParentCode %in% c('100', '200', '300', '400', '500')) %>% 
  select(CustomerID, ParentCode, Code, Name, Value, Point, Percentage, IsFinancial, AuthoriseDate.x)

# fill cac gia tri chi tieu vao
fin_indicator <- higher_level_indicator %>% 
  filter(ParentCode == 'I') %>% 
  inner_join(mtc, by = c("CustomerID" = "CustomerID", "Code" = "ParentCode")) %>% 
  select(CustomerID, NCT_ID = Code.x, NCT_NAME = Name.x, MA_CHITIEU = Code.y, TEN_CHITIEU = Name.y, 
         GIATRI_CHITIEU = Value, DIEM_CHITIEU = Point, TRONGSO_CHITIEU = Percentage, AuthoriseDate.x, IsFinancial )
  

nonfin_indicator <- higher_level_indicator %>% 
  filter(ParentCode == 'II') %>% 
  inner_join(mptc, by = c("CustomerID" = "CustomerID", "Code" = "ParentCode")) %>% 
  select(CustomerID, NCT_ID = Code.x, NCT_NAME = Name.x, MA_CHITIEU = Code.y, TEN_CHITIEU = Name.y, 
         GIATRI_CHITIEU = Value, DIEM_CHITIEU = Point, TRONGSO_CHITIEU = Percentage, AuthoriseDate.x, IsFinancial )


indicator <- fin_indicator %>% union(nonfin_indicator)

#-----------------------------------------------------------------------------
# DIEM TAI CHINH VA PHI TAI CHINH
# Note: Diem tai chinh KHONG NHAN trong so
#       Diem phi tai chinh  NHAN trong so

# tlb_CustomerFactor %>%
#   inner_join(tlb_Factor, by = c("FactorID" = "ID")) %>%
#   filter(ParentCode %in% c('I', 'II')) %>%
#   select(CustomerID, ParentCode, Code, Name, Value, Point, Percentage, IsFinancial) %>%
#   filter(CustomerID == '2367') %>% 
#   collect()

diem_taichinh <- tlb_CustomerFactor %>% 
  inner_join(tlb_Factor, by = c("FactorID" = "ID")) %>% 
  filter(ParentCode == 'I') %>% 
  group_by(CustomerID) %>% 
  summarise(DIEM_TAICHINH = sum(Point))


diem_phitaichinh <- tlb_CustomerFactor %>% 
  inner_join(tlb_Factor, by = c("FactorID" = "ID")) %>% 
  filter(ParentCode == 'II') %>% 
  group_by(CustomerID) %>% 
  summarise(DIEM_PHI_TAICHINH = sum(Point * Percentage))



#-----------------------------------------------------------------------------
# Bang CUSTOMER_FINANCIAL

scorecard <- tlb_Customer %>% 
  left_join(tlb_CompanyScale, by = c("CompanyScaleCode" = "Code"), suffix = c("", ".y")) %>% 
  left_join(diem_taichinh, by = c("ID"="CustomerID"), suffix = c("", ".y")) %>% 
  left_join(diem_phitaichinh, by = c("ID"="CustomerID"), suffix = c("", ".y")) %>% 
  left_join(indicator, by = c("ID"="CustomerID"), suffix = c("", ".y")) %>% 
  mutate(FREQUENCY = case_when(is.na(RatingPeriodID) ~ 'Dot Xuat', TRUE ~ 'Dinh Ki')) %>% 
  mutate(HANG_DIEU_CHINH = NA_character_ ) %>% 
  select(CUSTOMER_ID = Cif, BRANCH_CODE = CompanyID, ID_BANGHI = ID, 
         KI_CHAM_DIEM = RatingPeriodID, EFFECTIVE_DATE = AuthoriseDate.x,
         BCT_ID = CompanyScaleCode, BCT_NAME = Name, NCT_ID, 
         NCT_NAME,MA_CHITIEU, TEN_CHITIEU, GIATRI_CHITIEU, DIEM_CHITIEU, TRONGSO_CHITIEU,
         FREQUENCY, INDUSTRY_CODE1 = SbIndustryCode, INDUSTRY_CODE2 = IndustryCode, 
         QUY_MO = Name, DIEM_TAICHINH, DIEM_PHI_TAICHINH, TONG_DIEM = PointSum,
         HANG = RankingCode, HANG_DIEU_CHINH , IsFinancial) 

scorecard_2021 <- scorecard %>% collect()
  
rio::export(scorecard_2021, "scorecard_2021.csv")
