# FlowsDataManipulator
Poche righe di codice, scritte in R, per condurre un'analisi di variabilità delle feature in scenari differenti.

## Descrizione del workflow
* Il main richiama delle funzioni di supporto, in primis vengono caricati i dati per i diversi scenari. E' presente una lista di dataframe.
* Vengono selezionate le feature di interesse.
* Normalizzazione min-max delle colonne (feature) sottoposte ad analisi.
* Iterando sulle feature in analisi, per ciascuna viene valutata varianza, media, mediana e SIQR nei diversi scenari.
* In relazione al punto precedente, viene calcolata la varianza delle varianze, delle mediane, della media e del SIQR per la feature in analisi nei diversi scenari.
* I risultati del punto precedente (ad es. varianza delle mediane) rende conto della variabilità di quella feature cross-scenario. Per cui, risponde alla domanda "La feature quanto è infleunzata dalla modifica di scenario?"

## Requisiti
* R (si consiglia RStudio)
  
## Installazione
* Clona il repository
* Inserire nella directory data/combined i file CSV dei flussi. Li ho denominati combined in quanto aggregano train, test e validation (es. TRAIN0 + VAL0 + TEST0 = COMBINED0).
* Correggi i path nel codice
* Apri il main ed esegui
