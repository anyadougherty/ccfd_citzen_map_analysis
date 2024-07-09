import geopandas
map1 = "C:/Users/tur63939/Desktop/REDIST_PROJ/Congressional Redistricting/initial maps/complete redistricting/bipartisan_minimal_variance_plan_by_brandon_bechtel_2021-11-22/0ff7128879a85c20d0d54a55cf220bf7.shp"
poly_map1 = geopandas.read_file(map1)

precincts = "C:/Users/tur63939/Desktop/REDIST_PROJ/Current Maps/tl_2020_42_vtd20.shp"
poly_precincts = geopandas.read_file(precincts)

join_left = poly_precincts.sjoin(poly_map1, how="left")
join_left.to_file("C:/Users/tur63939/Desktop/REDIST_PROJ/Current Maps/brandon_bechtel_v2.shp")