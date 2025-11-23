
load_scenarios <- function(dirData, scenarios, flagNormal) {
  # Inizializza una lista (tipo un vettore, ma più flessibile) per contenere i dati
  lista_df <- list()
  
  # Carica i dati da ciascun file COMBINED*.csv e aggiunge colonna Scenario
  for (s in scenarios) { 
    file_path <- file.path(dirData, paste0("COMBINED", s, ".csv"))
    if (file.exists(file_path)) {
      df <- read.csv(file_path) # legge CSV e restituisce dataframe
      df$Scenario <- paste("Scenario", s) # aggiungo la colonna scenario e la popolo
      lista_df[[as.character(s)]] <- df # aggiungo il dataframe alla lista
    } else {
      warning(paste("File not found:", file_path))
    }
  }
  
  if (flagNormal) {
    lista_df <- lapply(lista_df, function(df) { # applico la funzione a tutti i dataframe della lista
      df[df$Label == "aNOR", ] # selezione solo le righe aNOR nel dataframe
    })
  }

  return(lista_df)
}