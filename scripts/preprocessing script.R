# set wd
setwd('C:/Users/tur63939/Desktop/REDIST_PROJ/Legislative Redistricting/Initial/Partial Redistricting Plans')

# load libraries
library(dplyr)
library(sf)

##### CSV
# read in file
lv_plan_bypc <- read.csv('lv_plan_by_pc_jan-19-2022.csv')

# filter file
lv_plan2 = lv_plan_bypc %>% select(c('GEOID20', 'District'))

# write csv
write.csv(lv_plan2, 'lv_plan_by_pc_jan-19-2022_v2.csv')

###### SHP
setwd("C:/Users/tur63939/Desktop/REDIST_PROJ/Legislative Redistricting/V2/Complete Plans")

cong_map <- st_read('us_house_map_by_jc_dec-15-2021.shp')

cong_map_v2 = cong_map %>% select(c('GEOID20', 'id'))
cong_map_v3 = st_drop_geometry(cong_map_v2)

# write csv
write.csv(cong_map_v3, 'us_house_map_by_jc_dec-15-2021_v2.csv')

###### SHP Congressional
setwd("C:/Users/tur63939/Desktop/REDIST_PROJ/Congressional Redistricting/v2")

cong_map <- st_read('464_MD_2021_465_MD_2021_Citizen_voters_shape_files.shp')

cong_map_v2 = cong_map %>% select(c('GEOID20', 'DISTRICT'))
cong_map_v3 = st_drop_geometry(cong_map_v2)

# write csv
write.csv(cong_map_v3, '464_MD_2021_465_MD_2021_Citizen_voters_shape_files_v2.csv')

gc()
##### Concordance Matrix
setwd("C:/Users/tur63939/Desktop/REDIST_PROJ/converting shp")
mydata <- st_read('precincts-blocks2.shp')
mydata2 = mydata %>% select(c('GEOID20', 'GEOID20_2'))
mydata2 = st_drop_geometry(mydata2)
colnames(mydata2)[1] = 'GEOID'
colnames(mydata2)[2] = 'GEOID20'
gc()
##### population based allocation
# 
setwd("C:/Users/tur63939/Desktop/REDIST_PROJ/preprocessing")

# load data and prep
geo_pa <- read.csv('geo_pa.csv')
pop_by_block <- read.csv('pop_by_block.csv')
colnames(pop_by_block)[2] <- "GEOID"
pop_by_block2 = pop_by_block %>% select(c('GEOID', 'P1_001N'))
geo_pa2  = geo_pa %>% select(c('GEOID20', 'pop', 'ndv', 'nrv'))
attempt1 = merge(x = mydata2, y = geo_pa2, by = 'GEOID20')
attempt2 = merge(x = attempt1, y = pop_by_block2, by = 'GEOID')

# create proportion and vote columns
attempt2$proportion = attempt2$P1_001N / attempt2$pop
attempt2$dem = attempt2$ndv * attempt2$proportion
attempt2$rep = attempt2$nrv * attempt2$proportion

write.csv(attempt2, 'population_based_vote_allocation2.csv')

pop_allo <- read.csv('population_based_vote_allocation.csv')
