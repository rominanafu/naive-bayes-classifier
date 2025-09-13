library(tidyverse)

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


### Clasificados naive Bayes utilizando libreria e1071
library(e1071)

# Convertimos a factor la variable objetivo
training$h_type = factor(training$h_type)
testing$h_type = factor(testing$h_type)

NB_cl = naiveBayes(h_type ~ ., data = training)
y_pred = predict(NB_cl, newdata = testing)

# Calculo de metricas
library(caret)
cm = confusionMatrix(y_pred, testing$h_type)
cm
