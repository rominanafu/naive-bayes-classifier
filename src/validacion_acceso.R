
library(robotstxt)
acceso = paths_allowed(paths = "/", domain = "www.yourghoststories.com", bot = "*")
cat("Acceso: ", acceso)
