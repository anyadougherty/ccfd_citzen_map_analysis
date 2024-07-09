# set wd
setwd('C:/Users/tur63939/Desktop/REDIST_PROJ')

# load libraries
library(redist)
library(redistmetrics)
library(ggredist)
library(geomander)
library(dplyr)
library(sf)
library(ggplot2)
library(patchwork)
library(tidyverse)
library("readxl")

# prep geo data
geo_pa = get_alarm(
  "PA",
  epsg = 3857
)
prison_alloc <- read_excel("2021 Prison Adjusted Census Population.xlsx")

# prep and merge data
colnames(prison_alloc)[1] <- "GEOID20"
prison_alloc2 = prison_alloc %>% select(c('GEOID20', 'P0010001'))
merged_data = merge(x = prison_alloc2, y = geo_pa, by = 'GEOID20')

sub_map <- read.csv('a_fair_congressional_plan_for_pennsylvania_by_mg_oct-26-2021_v2.csv')
colnames(sub_map)[2] <- "GEOID20"
colnames(sub_map)[3] <- "District"

# create redist map
joined_map = merge(x = merged_data, y = sub_map, by = 'GEOID20')
rd_map = redist_map(joined_map, existing_plan = District, total_pop = 'P0010001')

# make simulated plans
rd_plans = redist_smc(rd_map, nsims=100)

# preview simulated plans
redist.plot.plans(rd_plans, draws=c("District", "1", "2", "3"), shp=rd_map)

# prep analysis columns
# eventually add one for partisan bias
rd_plans = rd_plans %>% mutate(Compactness = comp_polsby(pl(), rd_map),
                               `Population deviation` = plan_parity(rd_map),
                               `Democratic vote` = group_frac(rd_map, ndv, (ndv + nrv)))
              
# compute metrics
# https://github.com/alarm-redist/redistmetrics/blob/main/vignettes/party.Rmd
part_dvs(plans = rd_map$District, shp = rd_map, dvote = ndv, rvote = nrv) # political bias
part_dseats(plans = rd_map$District, shp = rd_map, dvote = ndv, rvote = nrv) # computes num of democratic seats - GOOD
part_dvs(plans = rd_map$District, shp = rd_map, dvote = ndv, rvote = nrv) # vote share # may be useful

# visualize analysis
# histograms comparing population deviation and compactness
hist(rd_plans, `Population deviation`) + hist(rd_plans, Compactness)+
  plot_layout(guides="collect") +
  plot_annotation(title="Simulated plan characteristics")

# scatter plot comparing population deviation and compactness
redist.plot.scatter(rd_plans, `Population deviation`, Compactness) +
  labs(title="Population deviation and compactness by plan")

# displays democratic vote share of plans
plot(rd_plans, `Democratic vote`, size=0.5, color_thresh=0.5) +
  scale_color_manual(values=c("black", "tomato2", "dodgerblue")) +
  labs(title="Expected Partisan Outcome by district")

# Democratic vote share by district
redist.plot.plans(rd_plans, draws=c("District", "1", "2", "3"), shp=rd_map, qty = `Democratic vote`)

# compactness by district
redist.plot.plans(rd_plans, draws=c("District", "1", "2", "3"), shp=rd_map, qty = Compactness)



# metric comparisons between block and precinct assignments 
# blocks 
setwd("C:/Users/tur63939/Desktop/REDIST_PROJ/Congressional Redistricting/v2/block assignments 2")
# load data
block_Shp <- st_read("C:/Users/tur63939/Desktop/REDIST_PROJ/tl_2020_42_tabblock20/tl_2020_42_tabblock20.shp")
block_pop <- read.csv("C:/Users/tur63939/Desktop/REDIST_PROJ/preprocessing/pop_by_block.csv")
block_assign <- read.csv('democrats_favored_by_ej_reihl_2021-11-30_v2.csv')
vote_allo = read.csv("C:/Users/tur63939/Desktop/REDIST_PROJ/preprocessing/population_based_vote_allocation2.csv")

# change column names as necessary
colnames(block_assign)[3] <- "District"
colnames(block_pop)[2] <- 'GEOID'
colnames(block_Shp)[5] <- 'GEOID'
colnames(block_assign)[2] <- 'GEOID'

# join data
merge_blk = merge(x = block_Shp, y = block_pop, by = 'GEOID')
joined_blk = merge(x = merge_blk, y = block_assign, by = 'GEOID')
vote_merge = merge(x = joined_blk, y = vote_allo, by = 'GEOID')
base_plan  = vote_merge %>% select(c('GEOID20', 'GEOID', 'dem', 'rep', 'P1_001N.x', 'District'))

# create redistricting map
rd_map = redist_map(base_plan, existing_plan = District, total_pop = 'P1_001N.x')
rd_map[is.na(rd_map)] = 0

# metrics
part_dseats(plans = rd_map$District, shp = rd_map, dvote = dem, rvote = rep)
comp_polsby(plans = rd_map$District, shp = rd_map)
redist.parity(plans = rd_map$District, total_pop = rd_map$P1_001N.x)
part_dvs(plans = rd_map$District, shp = rd_map, dvote = dem, rvote = rep)

# precincts
setwd("C:/Users/tur63939/Desktop/REDIST_PROJ/Congressional Redistricting/v2/precinct assignments")

# load data
precinct_Shp <- st_read("C:/Users/tur63939/Desktop/REDIST_PROJ/Current Maps/tl_2020_42_vtd20.shp")
precinct_pop <- read.csv("C:/Users/tur63939/Desktop/REDIST_PROJ/preprocessing/geo_pa.csv")
precinct_assign <- read.csv('democrats_favored_by_ej_reihl_2021-11-30_v2.csv')

# change column names as necessary
colnames(precinct_assign)[3] <- "District"

# join data
merge_prec = merge(x = precinct_Shp, y = precinct_pop, by = 'GEOID20')
joined_prec = merge(x = merge_prec, y = precinct_assign, by = 'GEOID20')
base_plan2  = joined_prec %>% select(c('GEOID20', 'ndv', 'nrv', 'pop', 'District'))

# create redistricting map
rd_map2 = redist_map(base_plan2, existing_plan = District, total_pop = 'pop')

# metrics
part_dseats(plans = rd_map2$District, shp = rd_map2, dvote = ndv, rvote = nrv)
comp_polsby(plans = rd_map2$District, shp = rd_map2)
redist.parity(plans = rd_map2$District, total_pop = rd_map2$pop)
part_dvs(plans = rd_map2$District, shp = rd_map2, dvote = ndv, rvote = nrv)
