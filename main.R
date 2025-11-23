# Load libraries
library(ggplot2)
library(dplyr)

setwd("C:\\Users\\rober\\Desktop\\dataAanalysis")
getwd()

source("R\\utils.R")
source("R\\loadData.R")

# Load data
dirData <- "C:\\Users\\rober\\Desktop\\dataAanalysis\\data\\combined" # Directory in winch is contained the COMBINED files
scenarios <- c(0, 1, 2, 3, 4, 5, 8, 10, 15) # List of scenarios
lista_df <- load_scenarios(dirData, scenarios, TRUE)

# Queste sono le feature per le quali si vuole valutare la variabilità cross-scenario
selectedFeatures <- c('Flow Duration','Total Fwd Packet',
                         'Total Bwd packets','Total Length of Fwd Packet','Total Length of Bwd Packet','Fwd Packet Length Max',
                         'Fwd Packet Length Min','Fwd Packet Length Mean','Fwd Packet Length Std','Bwd Packet Length Max','Bwd Packet Length Min',
                         'Bwd Packet Length Mean','Bwd Packet Length Std','Flow Bytes/s','Flow Packets/s','Flow IAT Mean','Flow IAT Std',
                         'Flow IAT Max','Flow IAT Min','Fwd IAT Total','Fwd IAT Mean','Fwd IAT Std','Fwd IAT Max','Fwd IAT Min','Bwd IAT Total',
                         'Bwd IAT Mean','Bwd IAT Std','Bwd IAT Max','Bwd IAT Min','Fwd PSH Flags','Bwd PSH Flags','Fwd URG Flags',
                         'Bwd URG Flags','Fwd RST Flags','Bwd RST Flags','Fwd Header Length','Bwd Header Length','Fwd Packets/s',
                         'Bwd Packets/s','Packet Length Min','Packet Length Max','Packet Length Mean','Packet Length Std','Packet Length Variance',
                         'FIN Flag Count','SYN Flag Count','RST Flag Count','PSH Flag Count','ACK Flag Count','URG Flag Count','CWR Flag Count',
                         'ECE Flag Count','Down/Up Ratio','Average Packet Size','Fwd Segment Size Avg','Bwd Segment Size Avg','Fwd Bytes/Bulk Avg',
                         'Fwd Packet/Bulk Avg','Fwd Bulk Rate Avg','Bwd Bytes/Bulk Avg','Bwd Packet/Bulk Avg','Bwd Bulk Rate Avg',
                         'Subflow Fwd Packets','Subflow Fwd Bytes','Subflow Bwd Packets','Subflow Bwd Bytes','FWD Init Win Bytes',
                         'Bwd Init Win Bytes','Fwd Act Data Pkts','Bwd Act Data Pkts','Fwd Seg Size Min','Bwd Seg Size Min','Active Mean',
                         'Active Std','Active Max','Active Min','Idle Mean','Idle Std','Idle Max','Idle Min',
                         'Fwd TCP Retrans. Count','Bwd TCP Retrans. Count','Total TCP Retrans. Count','Total Connection Flow Time')

selectedFeatures <- make.names(selectedFeatures) # modifico le stringhe per farli diventare nomi R validi (sostituisce spazi con punti)

lista_df_norm <- lapply(lista_df, function(df) { # applico la funzione a tutti i dataframe della lista
  
  # loop sulle colonne da normalizzare
  for (feat in selectedFeatures) { # per ciascuna feature selezionata
    if (feat %in% colnames(df)) { # se esiste
      df[[feat]] <- min_max_norm(df[[feat]]) # normalizzazione min-max della colonna
    }
  }
  
  return(df)
})

# Inizialitazione dataframe for results
risultati <- data.frame()

for (feat in selectedFeatures) {
  
  mediane   <- c()  # vettore delle mediane per scenario
  siqr       <- c()  # vettore degli SIQR
  medie     <- c()  # vettore delle medie normalizzate
  varianze  <- c()  # vettore delle varianze normalizzate
  
  for (s in scenarios) {
    df_s <- lista_df[[as.character(s)]] # Accedo ad uno specifico dataframe della lista (identificato dallo scenario)
    if (is.null(df_s[[feat]])) {
      warning(paste("Feature", feat, "non trovata in scenario", s))
      mediane  <- c(mediane,  NA)
      siqr     <- c(siqr,     NA)
      medie    <- c(medie,    NA)
      varianze <- c(varianze, NA)
      next
    }
    
    # estrai la colonna e normalizza
    x_norm <- min_max_norm(df_s[[feat]]) # Estrae la colonna feat (sto iterando sulle feature) dal dataframe
    
    mediane  <- c(mediane,  median(x_norm, na.rm=TRUE)) # concateno i valori delle mediane della feature selezionata sui diversi scenari
    siqr     <- c(siqr,     SIQR(x_norm))
    medie    <- c(medie,    mean(x_norm, na.rm=TRUE))       
    varianze <- c(varianze, var(x_norm, na.rm=TRUE))  
  }
  
  # qui calcoliamo le 4 varianze inter‑scenario
  var_median    <- var(mediane,   na.rm=TRUE)
  var_siqr      <- var(siqr,      na.rm=TRUE)
  var_media     <- var(medie,     na.rm=TRUE)
  var_varianza  <- var(varianze,  na.rm=TRUE)
  
  risultati <- rbind(risultati, 
                     data.frame(
                       Feature        = feat, 
                       Var_Mediana    = var_median,
                       Var_SIQR       = var_siqr,
                       Var_Media      = var_media,
                       Var_Varianza   = var_varianza
                     ))
}

# ---- ordino e stampo risultati ----
risultati <- risultati %>% 
  arrange(desc(Var_SIQR))  # lasci invariato, o ordina anche per Var_Media/Var_Varianza

print(risultati)


# Esempio di chiamata
plot_top_n(risultati, var_type = "Var_Mediana", n = 20,
           label_size = 14, axis_title_size = 14, title_size = 16)

# Stampo etichette feature ultime n colonne
ultimi <- tail(risultati$Feature, 65)
cat(paste0("'", ultimi, "'", collapse = ", "))

