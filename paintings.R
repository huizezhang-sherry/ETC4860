library(rvest)
library("EBImage")
library(stringr)
library(dplyr)
library(ggplot2)

paint <- read.csv("data/paint_data_clean.csv", stringsAsFactors=FALSE, row.names=1)
paint_long <- read.csv("data/paint_data.csv", stringsAsFactors=FALSE, row.names=1)
dim(paint)
paint[1,]

# Scraping the data, Sam's code
paintings <- html("http://www.saleoilpaintings.com/paintings/bob-ross/bob-ross-sale-3_1.html") 
images <- paintings %>% html_nodes("img") %>% html_attr("src")
remove <- which(images == "/image/buy-art.gif") #logo for website repeated over and over 
paintings2 <- images[-remove] #get rid of logo
paintings2 <- paintings2[-(1:4)]
img_urls <- paste("http://www.saleoilpaintings.com",paintings2,sep='')
img_urls2 <- img_urls[grep(".jpg",img_urls)] #only get jpgs, not gifs
for (i in 1:length(img_urls2)){
  destination <- paste("data/paintings/bobross",i,".jpg",sep='')
  download.file(url = img_urls2[i], destfile = destination) 
}

# Pull off the names
painting_name <- paintings2
for (i in 1:length(paintings2)) 
  painting_name[i] <- substr(paintings2[i], 37, str_length(paintings2[i]))
for (i in 1:length(paintings2)) 
  painting_name[i] <- substr(painting_name[i], 1, (str_length(painting_name[i])-10))
painting_name[148] <- "noname"
painting_name[229] <- "jon-baldwin-art"
painting_name[67] <- "tom-evans"
painting_name[7] <- "impressions-in-oil-0"
painting_name[8] <- "impressions-in-oil-1"
painting_name[9] <- "impressions-in-oil-2"
sort(table(painting_name))
#indx <- c(1:242)[painting_name=="impressions-in-oil"]
#for (i in 1:length(indx))
#  painting_name[indx[i]] <- paste("impressions-in-oil-",i-1,sep="")
tb <- data.frame(table(painting_name))
tb <- filter(tb, Freq > 1)
for (j in 1:nrow(tb)) {
  indx <- c(1:242)[painting_name==as.character(tb$painting_name[j])]
  for (i in 1:length(indx))
    painting_name[indx[i]] <- paste(as.character(tb$painting_name[j]),i,sep="-")
}
for (i in 1:length(indx))
  painting_name[indx[i]] <- paste("mountain-sunset-",i-1,sep="")
painting_name[27] <- "mountain-lake-0"
painting_name[81] <- "mountain-lake-1"
painting_name[213] <- "mountain-lake-2"

df <- filter(paint_long, id == 1)
qplot(x, -y, data=df, fill=Hcolor, geom="tile") + scale_fill_identity(labels=df$Hcolor)

df <- filter(paint_long, id == 2)
qplot(x, -y, data=df, fill=Hcolor, geom="tile") + scale_fill_identity(labels=df$Hcolor)

x <- readImage("data/paintings/bobross1.jpg")
display(x)
y <- resize(x, 20, 20)
display(y)

df <- data.frame(x=rep(1:20, 20), y=rep(1:20, rep(20,20)), r=as.vector(y[,,1]), g=as.vector(y[,,2]), b=as.vector(y[,,3]))
df$h <- rgb(df[,3:5])

qplot(x, -y, data=df, fill=h, geom="tile") + scale_fill_identity(labels=df$h)

paint_long2 <- NULL
for (i in 1:242) {
  x <- readImage(paste("data/paintings/bobross", i, ".jpg", sep=""))
  if (length(dim(x)) > 2) {
    y <- resize(x, 20, 20)
    df <- data.frame(x=rep(1:20, 20), y=rep(1:20, rep(20,20)), r=as.vector(y[,,1]), g=as.vector(y[,,2]), b=as.vector(y[,,3]))
    df$h <- rgb(df[,3:5])
    df$name <- painting_name[i]
    df$id <- i
    paint_long2 <- rbind(paint_long2, df)
    cat(i,"\n")
  }
}

df <- filter(paint_long2, id == 5)
qplot(x, -y, data=df, fill=h, geom="tile") + scale_fill_identity(labels=df$h)

ids <- unique(paint_long2$id)
paint2 <- data.frame(matrix(0, ncol = 2+400*3, nrow = length(ids)))
column.names <- c("id", "name", paste(c('r','g','b'),rep(1:400,each=3), sep='')) # 1200 variables. p >> n names(paint.df) <- c('id', column.names)
for (id in 1:length(ids)) {
  for (i in 1:400) {
    j <- (id-1)*400 + i
    paint2[id, 2+(3*(i-1)+1)] <- paint_long2[j,3]
    paint2[id, 2+(3*(i-1)+2)] <- paint_long2[j,4] 
    paint2[id, 2+(3*(i-1)+3)] <- paint_long2[j,5]
  } 
}
colnames(paint2) <- column.names

# Check results
paint2[1,1:12]
head(paint_long2)
summary(paint2$r1)

paint2$id <- unique(paint_long2$id)
paint2$name <- unique(paint_long2$name)

forest <- grep("forest", paint2$name)
wood <- grep("wood", paint2$name)
meadow <- grep("meadow", paint2$name)
mountain <- grep("mountain", paint2$name)
land <- grep("land", paint2$name)
pines <- grep("pine", paint2$name)
trail <- grep("trail", paint2$name)
nature <- grep("nature", paint2$name)
scenic <- grep("scenic", paint2$name)
beauty <- grep("beauty", paint2$name)
haven <- grep("haven", paint2$name)
country <- grep("country", paint2$name)
paradise <- grep("paradise", paint2$name)
happy <- grep("happy", paint2$name)
majesty <- grep("majest", paint2$name)
impressions <- grep("impressions", paint2$name)
lake <- grep("lake", paint2$name)
ocean <- grep("ocean", paint2$name)
falls <- grep("falls", paint2$name)
waterfall <- grep("waterfall", paint2$name)
brook <- grep("brook", paint2$name)
water <- grep("water", paint2$name)
river <- grep("river", paint2$name)
wave <- grep("wave", paint2$name)
angler <- grep("angler", paint2$name)
fisherman <- grep("fisherman", paint2$name)
stream <- grep("stream", paint2$name)
sea <- grep("seascape", paint2$name)
storm <- grep("storm", paint2$name)
marine <- grep("marine", paint2$name)
reflection <- grep("reflection", paint2$name)
season <- grep("season", paint2$name)
flower <- grep("flower", paint2$name)
pansies <- grep("pansies", paint2$name)
rose <- grep("rose", paint2$name)
dais <- grep("dais", paint2$name)
garden <- grep("garden", paint2$name)
summer <- grep("summer", paint2$name)
winter <- grep("winter", paint2$name)
snow <- grep("snow", paint2$name)
glacier <- grep("glacier", paint2$name)
lonely <- grep("lonely", paint2$name)
silent <- grep("silent", paint2$name)
spring <- grep("spring", paint2$name)
autumn <- grep("autumn", paint2$name)
sunset <- grep("sunset", paint2$name)
dawn <- grep("dawn", paint2$name)
aurora <- grep("aurora", paint2$name)
twilight <- grep("twilight", paint2$name)
evening <- grep("evening", paint2$name)
azure <- grep("azure", paint2$name)
sky <- grep("sky", paint2$name)
rain <- grep("rain", paint2$name)
skies <- grep("skies", paint2$name)
moon <- grep("moon", paint2$name)
cabin <- grep("cabin", paint2$name)
farm <- grep("farm", paint2$name)
oval <- grep("oval", paint2$name)

scenes <- sort(unique(c(mountain, land, beauty, scenic, farm, cabin, nature, haven, country, paradise, happy, majesty)))
trees <- sort(unique(c(forest, wood, pines, trail, meadow)))
h2o <- sort(unique(c(water, falls, lake, ocean, brook, river, wave, stream, angler, fisherman, reflection, rain, sea, marine, storm)))
flowers <- sort(unique(c(flower, pansies, rose, dais, garden, spring, autumn, season, summer)))
cold <- sort(unique(c(winter, snow, glacier, lonely, silent)))
dusk <- sort(unique(c(sunset, dawn, twilight, aurora, evening, skies, sky, moon, azure)))
oval
impressions

all.classes <- sort(unique(c(scenes, trees, h2o, flowers, cold, dusk, oval, impressions)))
length(all.classes)
paint2$name[-all.classes]

paint2$class <- NA
paint2$class[scenes] <- "scene"
paint2$class[trees] <- "trees"
paint2$class[h2o] <- "water"
paint2$class[flowers] <- "flowers"
paint2$class[cold] <- "cold"
paint2$class[dusk] <- "dusk"
paint2$class[oval] <- "oval"
paint2$class[impressions] <- "impressions"
paint2$class[is.na(paint2$class)]

x <- sort(table(c(scenes, trees, h2o, flowers, cold, dusk, oval, impressions)))
x[x>1]
paint2$name[x>1]

paint2.sorted <- arrange(paint2, class)
indx <- sort(c(sample(1:29, 6), sample(30:66, 7), sample(67:93, 5), sample(94:114, 4), sample(115:121, 2), 
       sample(122:156, 7), sample(157:179, 5), sample(180:223, 9), 224:241))
paint2.tr <- paint2.sorted[-indx,]
paint2.ts <- paint2.sorted[indx,]
paint2.tr <- arrange(paint2.tr, id)
paint2.tr <- paint2.tr[,c(1,2,1203,3:1202)]
paint2.ts <- arrange(paint2.ts, id)
paint2.ts <- paint2.ts[,c(1,2,1203,3:1202)]

write.csv(paint2.tr, file="data/paintings-train.csv", row.names=F)
write.csv(paint2.ts, file="data/paintings-test.csv", row.names=F)
paint2.ts.unlabelled <- paint2.ts
paint2.ts.unlabelled$id <- NA
paint2.ts.unlabelled$name <- NA
paint2.ts.unlabelled$class <- NA
write.csv(paint2.ts.unlabelled, file="data/paintings-test-unlabelled.csv", row.names=F)

write.csv(paint2.ts[,c(1,3)], file="data/paintings-test-solution.csv", row.names=F)
paint2.ts.sample <- paint2.ts[,c(1,3)]
paint2.ts.sample$class <- paint2.ts.sample$class[sample(1:63, replace=T)]
write.csv(paint2.ts.sample, file="data/paintings-test-sample.csv", row.names=F)

paint2_long.tr <- filter(paint_long2, id %in% paint2.tr$id)
paint2_long.ts <- filter(paint_long2, id %in% paint2.ts$id)

paint2_long.tr$class <- NA
cls <- unique(paint2$class)
for (i in 1:8) {
  ids <- paint2$id[paint2$class == cls[i]]
  ids <- ids[!is.na(ids)]
  paint2_long.tr$class[paint2_long.tr$id %in% ids] <- cls[i]
}
paint2_long.ts$class <- NA
cls <- unique(paint2$class)
for (i in 1:8) {
  ids <- paint2$id[paint2$class == cls[i]]
  ids <- ids[!is.na(ids)]
  paint2_long.ts$class[paint2_long.ts$id %in% ids] <- cls[i]
}

paint2_long.ts$class <- NA
cls <- unique(paint2$class)
for (i in 1:8) {
  ids <- paint2.ts$id[paint2.ts$class == cls[i]]
  ids <- ids[!is.na(ids)]
  paint2_long.ts$class[paint2_long.ts$id %in% ids] <- cls[i]
}

write.csv(paint2_long.tr, file="data/paintings-long-train.csv", row.names=F)
write.csv(paint2_long.ts, file="data/paintings-long-test.csv", row.names=F)
paint2_long.ts.unlabelled <- paint2_long.ts
paint2_long.ts.unlabelled$id <- NA
paint2_long.ts.unlabelled$name <- NA
paint2_long.ts.unlabelled$class <- NA
write.csv(paint2_long.ts.unlabelled, file="data/paintings-long-test-unlabelled.csv", row.names=F)

write.csv(indx, file="data/paintings-test-indices.csv", row.names=F)

# classification
library(randomForest)
paint2.tr$class <- factor(paint2.tr$class)
p2.tr.rf <- randomForest(class~., data=paint2.tr[,-c(1:2)], importance=T, confusion=T)
p2.tr.rf
imp <- data.frame(p2.tr.rf$importance)
p2.tr.rf$importance[1:2,]
imp$var <- rownames(p2.tr.rf$importance)
imp <- arrange(imp, desc(MeanDecreaseGini))
imp$var <- factor(imp$var, levels=imp$var)
qplot(1:1200, imp$MeanDecreaseGini) + xlim(1,50)
qplot(1:1200, sort(imp$trees, decreasing=T)) + xlim(1,50)
imp$var[order(imp$trees, decreasing=T)][1:2]
# b308 b307 is important for trees
qplot(1:1200, sort(imp$impressions, decreasing=T)) + xlim(1,50)
imp$var[order(imp$impressions, decreasing=T)][1:10]
qplot(1:1200, sort(imp$cold, decreasing=T)) + xlim(1,50)
imp$var[order(imp$cold, decreasing=T)][1:10]
# r293 r313 b317 b295 g334 b343 b297 r274 r354 b67 

ts.p <- predict(p2.tr.rf, paint2.ts)

# Compute errors to match with kaggle
x <- as.matrix(addmargins(table(paint2.ts$class, ts.p)))
diag(x) <- 0
x <- x[-9,]
mean(apply(x, 1, function(x) sum(x[-9])/x[9]))
sum(x[,-9])/sum(x[,9])
tr.ts <- data.frame(paint2.ts$class, ts.p)


# For submission
ts.submit <- data.frame(id=paint2.ts$id, class=ts.p)
write.csv(ts.submit, file="paintings-submit.csv", row.names=F)

# Plot the long form to examine red/green/blue components by class
qplot(class, r, data=paint2_long.tr, geom="boxplot")
qplot(class, g, data=paint2_long.tr, geom="boxplot")
qplot(class, b, data=paint2_long.tr, geom="boxplot")

qplot(r, g, data=paint2_long.tr, alpha=I(0.3)) + facet_wrap(~class) + theme_bw() 
qplot(r, b, data=paint2_long.tr, alpha=I(0.3)) + facet_wrap(~class) + theme_bw() 
qplot(g, b, data=paint2_long.tr, alpha=I(0.3)) + facet_wrap(~class) + theme_bw() 

p_l.tr.av <- summarise(group_by(paint2_long.tr, id), 
                       r=mean(r), g=mean(g), b=mean(b))
p_l.tr.av <- merge(p_l.tr.av, paint2.tr[,1:3])

qplot(class, r, data=p_l.tr.av, geom="boxplot")
qplot(class, g, data=p_l.tr.av, geom="boxplot")
qplot(class, b, data=p_l.tr.av, geom="boxplot")

qplot(r, g, data=p_l.tr.av) + facet_wrap(~class) + theme_bw() + theme(aspect.ratio=1)
qplot(r, b, data=p_l.tr.av) + facet_wrap(~class) + theme_bw() + theme(aspect.ratio=1)
qplot(g, b, data=p_l.tr.av) + facet_wrap(~class) + theme_bw() + theme(aspect.ratio=1)
