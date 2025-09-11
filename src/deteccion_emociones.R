
library(syuzhet)

## Leer historias
data = read.delim("data/histories.csv", sep=";")

## Analizar sentimientos
nrc_data = get_nrc_sentiment(data$history)

## Guardar en csv
write.csv(nrc_data, "data/emotions.csv", row.names=F)
