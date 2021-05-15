
# loading libraries and functions
require(maps)
require(ggplot2)

source('../../../../mobility/utils/mobility_functions.R')

# loading coordinates
x = read.csv('../../../data/asos/1min/all_1min_latlon.txt')
y = x$station

cat('Airports #:', length(y), '\n')

# loading the map, using the function from mobility
mp = gplot.map.raw(x$lat, x$lon, type='osm', col=2, adj=0.1, size=0.8, shape=19)

p = mp + theme_bw() + xlab('Longitude') + ylab('Latitude') + 
    theme(text=element_text(size=26))

ggsave('img/map_1min.pdf', p, width=15)

# TODO: only used when visualizing in R
#    theme(family="Sans")) 


quit()

#p + scale_color_gradient(low="blue", high="red")

########

# testing other examples

xm = data.frame(lat=x$lat, lon=x$lon, col=2)
xm2 = as.data.frame(projectMercator(xm$lat, xm$lon))


mp <- openmap(c(53.38332836757155,-130.517578125),
c(15.792253570362446,-67.939453125),4,'osm')

#c(15.792253570362446,-67.939453125),4,'stamen-watercolor')

#mp_bing <- openmap(c(53.38332836757155,-130.517578125),
#c(15.792253570362446,-67.939453125),4,'bing')

states_map <- map_data("state")
states_map_merc <- as.data.frame(
projectMercator(states_map$lat,states_map$long))

states_map_merc$region <- states_map$region
states_map_merc$group <- states_map$group


p <- autoplot.OpenStreetMap(mp,expand=FALSE) + 
    geom_polygon(aes(x=x,y=y,group=group),
    data=states_map_merc,fill="black",colour="black",alpha=.1) + 
    geom_point(data=xm2, aes(x=x, y=y), col='blue', size=3) +
    theme_bw() + theme(text=element_text(size=26)
    #theme_bw() + theme(text=element_text(size=26,  family="Sans"))

#crimes <- data.frame(state = tolower(rownames(USArrests)), USArrests)
#print(p)
#p <- autoplot.OpenStreetMap(mp_bing) + geom_map(aes(x=-10000000,y=4000000,map_id=state,fill=Murder),
#data=crimes,map=states_map_merc)
#print(p)
