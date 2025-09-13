vectors = read.csv("../data/histories_vectorized.csv")

quitar = c()
for (c in names(vectors)) {
  s = sum(vectors[c])
  if (s < 5) {
    quitar = c(quitar, c)
  }
}
vectors = select(vectors, -quitar)

write.csv(vectors, "../data/histories_vectorized.csv", row.names=F)