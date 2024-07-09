import geopandas
import pandas as pd

# import map
map1 = "C:/Users/tur63939/Desktop/REDIST_PROJ/Congressional Redistricting/initial maps/court case submissions/shapefiles/464_MD_2021_465_MD_2021_Citizen_voters_shape_files/CitizenVoters.shp"
poly_map1 = geopandas.read_file(map1)

# reproject the shapefile using the EPSG code if necessary
print(poly_map1.crs)
poly_map2 = poly_map1.to_crs(epsg=4269)

## precinct assignments
# import precincts points
precincts = "C:/Users/tur63939/Desktop/REDIST_PROJ/converting shp/precinct_points.shp"
poly_precincts = geopandas.read_file(precincts)

# left join precincts and congressional assignments
join_left = poly_precincts.sjoin(poly_map2, how="left")
join_left.to_file("C:/Users/tur63939/Desktop/REDIST_PROJ/Congressional Redistricting/v2/464_MD_2021_465_MD_2021_Citizen_voters_shape_files.shp")

## block assignments
# import block points
blocks = "C:/Users/tur63939/Desktop/REDIST_PROJ/converting shp/block_points2.shp"
poly_blocks = geopandas.read_file(blocks)

# left join blocks and congressional assignments 
join_left_blk = poly_blocks.sjoin(poly_map2, how="left")
join_left_blk.to_file("C:/Users/tur63939/Desktop/REDIST_PROJ/Congressional Redistricting/v2/464_MD_2021_465_MD_2021_Citizen_voters_shape_files.shp")

###############
# pre processing population by block data
popdata = pd.read_csv("C:/Users/tur63939/Desktop/REDIST_PROJ/preprocessing/DECENNIALPL2020.P1_2024-06-26T115350/DECENNIALPL2020.P1-Data.csv")

# view columns
popdata.head()

# drop columns that are not census blocks
popdata = popdata.drop(labels=[0, 1], axis = 0)

# remove the leading '1000000US' from each geoid
popdata['GEO_ID'] = popdata['GEO_ID'].str.replace('1000000US', '')

# create new file
popdata.to_csv('C:/Users/tur63939/Desktop/REDIST_PROJ/preprocessing/pop_by_block.csv')

############## population metrics
# blocks
pop_block = pd.read_csv("C:/Users/tur63939/Desktop/REDIST_PROJ/preprocessing/population_based_vote_allocation2.csv")
block_assign = pd.read_csv("C:/Users/tur63939/Desktop/REDIST_PROJ/Congressional Redistricting/v2/block assignments 2/competitive_districts_mp_by_matthew_price_2021-12-03_v2.csv")

block_assign2 = block_assign.rename(columns={"GEOID20" : "GEOID"})

merged_data = pd.merge(block_assign2, pop_block, on='GEOID')

filtered_data = merged_data[merged_data['DISTRICTNO'] == 17]
sumpop = filtered_data['P1_001N'].sum()
print(sumpop)

## precincts
pop_prec = pd.read_csv("C:/Users/tur63939/Desktop/REDIST_PROJ/preprocessing/geo_pa.csv")
prec_assign = pd.read_csv("C:/Users/tur63939/Desktop/REDIST_PROJ/Congressional Redistricting/v2/precinct assignments/competitive_districts_mp_by_matthew_price_2021-12-03_v2.csv")

merged_data2 = pd.merge(prec_assign, pop_prec, on='GEOID20')
merged_data2.head()
filtered_data2 = merged_data2[merged_data2['DISTRICTNO'] == 1]
sumpop2 = filtered_data2['pop'].sum()
print(sumpop2)