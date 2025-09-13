library(naivebayes)
library(tidyverse)
library(caret)

## Lectura de datos
info = read.delim2("../data/histories.csv", sep=";")
vectors = read.csv("../data/histories_vectorized.csv")
emotions = read.csv("../data/emotions.csv")

## Modificar nombres de columnas en emotions e info para evitar repetición con vectors
colnames(info) = paste(colnames(info), "_info", sep="")
colnames(emotions) = paste(colnames(emotions), "_emotions", sep="")

## Eliminar la historia completa (se encuentra incluída implícitamente en la sparse matrix)
data = cbind(select(info, -c(history_info, h_type_info)), emotions, vectors)

## Ver cuántas historias hay por clasificación
history_type = unique(info$h_type)
for (type in history_type) {
  cat(type, ": ", sum(info$h_type == type), "\n", sep="")
}

## Dividir en training y testing sets
n1 = length(which(info$h_type_info == "Haunted Places"))
n1_70 = round(n1 * .7)
n2 = length(which(info$h_type_info != "Haunted Places"))
n2_70 = round(n2 * .7)
### training
training_haunted_places = data[which(info$h_type_info == "Haunted Places")[1 : n1_70],] # 70% de historias de Haunted Places
training_non_haunted_places = data[which(info$h_type_info != "Haunted Places")[1 : n2_70], ] # 70% de historias que no son Haunted Places
training = rbind(cbind(training_haunted_places, h_type="Haunted Places"),
                 cbind(training_non_haunted_places, h_type="Non Haunted Places"))
### testing
testing_haunted_places = data[which(info$h_type_info == "Haunted Places")[(n1_70+1) : n1], ] # 30% de historias de Haunted Places
testing_non_haunted_places = data[which(info$h_type_info != "Haunted Places")[(n2_70+1) : n2], ] # 30% de historias que no son Haunted Places
testing = rbind(cbind(testing_haunted_places, h_type="Haunted Places"),
                cbind(testing_non_haunted_places, h_type="Non Haunted Places"))


## Convertir a factores las variables categóricas
### Place
tr = unique(training$place_info)
te = unique(testing$place_info)
lev = union(tr, te)
training$place_info = factor(training$place_info, levels=lev)
testing$place_info = factor(testing$place_info, levels=lev)
### History type
training$h_type = factor(training$h_type)
testing$h_type = factor(testing$h_type)

# Clasificadores

## Métricas de matriz de confusión
prediccion_metricas = function(poi, lapl) {
  NB_cl = naive_bayes(select(training, -c(h_type, title_info)),
                      training$h_type,
                      usepoisson=poi,
                      laplace=lapl)
  pred = predict(NB_cl, select(testing, -c(h_type, title_info)))
  cm = confusionMatrix(pred, testing$h_type)
  cat("\n\nClasificador Naïve Bayes con paquete naivebayes, poisson=", poi,
      ", Laplace=", lapl, "\n", sep="")
  cm
}

## clasificador sin parámetros
prediccion_metricas(F, 0)

## usepoisson = T
prediccion_metricas(T, 0)

## Laplace smoothing
prediccion_metricas(T, 0.1)
