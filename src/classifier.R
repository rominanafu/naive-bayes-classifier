
library(tidyverse)

## Lectura de datos
info = read.delim2("../data/histories.csv", sep=";")
vectors = read.csv("../data/histories_vectorized.csv")
emotions = read.csv("../data/emotions.csv")

## Eliminar la historia completa (se encuentra incluída implícitamente en la sparse matrix)
data = cbind(select(info, -c(history, h_type)), emotions, vectors)

## Ver cuántas historias hay por clasificación
history_type = unique(info$h_type)
for (type in history_type) {
  cat(type, ": ", sum(info$h_type == type), "\n", sep="")
}

## Dividir en training y testing sets
n1 = length(which(info$h_type == "Haunted Places"))
n1_70 = round(n1 * .7)
n2 = length(which(info$h_type != "Haunted Places"))
n2_70 = round(n2 * .7)
### training
training_haunted_places = data[which(info$h_type == "Haunted Places")[1 : n1_70],] # 70% de historias de Haunted Places
training_non_haunted_places = data[which(info$h_type != "Haunted Places")[1 : n2_70], ] # 70% de historias que no son Haunted Places
training = rbind(cbind(training_haunted_places, type="Haunted Places"),
                 cbind(training_non_haunted_places, type="Non Haunted Places"))
### testing
testing_haunted_places = data[which(info$h_type == "Haunted Places")[(n1_70+1) : n1], ] # 30% de historias de Haunted Places
testing_non_haunted_places = data[which(info$h_type != "Haunted Places")[(n2_70+1) : n2], ] # 30% de historias que no son Haunted Places
testing = rbind(cbind(testing_haunted_places, type="Haunted Places"),
                cbind(testing_non_haunted_places, type="Non Haunted Places"))
