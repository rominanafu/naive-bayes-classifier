
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

## Clasificador Naïve Bayes manual

### Prior
prior = training |>
  group_by(h_type) |>
  summarise(n = n()) |>
  mutate(prior_prob = n/sum(n))
prior

### Multinomial: place_info
cat_probs = training |>
  group_by(h_type, place_info) |>
  summarise(n = n()) |>
  group_by(h_type) |>
  mutate(prob = n / sum(n))
cat_probs
#### Manejar casos de lugares que se encuentren en el testing set y no en el training
tr = unique(training$place_info)
te = unique(testing$place_info)
for (t in te) {
  if (!(t %in% tr)) {
    cat_probs = rbind(cat_probs, data.frame(h_type=c("Haunted Places", "Non Haunted Places"),
                                            place_info=c(t, t),
                                            n=c(0,0),
                                            prob=c(0,0)))
  }
}

### Normal: Todas las variables continuas
continuous_vars = colnames(training)[which(!(colnames(training) %in% c("h_type", "place_info", "title_info")))]
bws = training |>
  group_by(h_type) |>
  summarise(across(continuous_vars, ~ density(.x)$bw, .names="bw_{.col}"))
bws
