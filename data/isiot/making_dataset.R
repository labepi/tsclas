# just to adjust the columns of the dataset

# adding names per row

# loading data
x = read.csv('wunder_2015.csv', header=F)

# loading names
names = read.csv('cities.usa.csv')

# isolating names
names = rep(names[,3], each=4)

# adding names
x = cbind(names, x)

# saving
write.table(x, 'wunder_2015.csv', row.names=F, col.names=F, sep=',')

