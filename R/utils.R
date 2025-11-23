
# Funzione per calcolare il SIQR
SIQR <- function(x) {
  q75 <- quantile(x, 0.75, na.rm = TRUE)
  q25 <- quantile(x, 0.25, na.rm = TRUE)
  return((q75 - q25) / 2)
}

min_max_norm <- function(x) {
  x <- na.omit(x)  # rimuove NA temporaneamente
  if (length(x) == 0 || max(x, na.rm = TRUE) == 0) {
    return(rep(0, length(x)))  # se tutti 0 o vuota, restituisci 0
  } else {
    return(x / max(x, na.rm = TRUE))
  }
}

# df: data.frame con colonne Feature, Var_Mediana, Var_SIQR
# var_type: string, "Var_Mediana" o "Var_SIQR"
# n: numero di feature da mostrare (le prime n con valore più alto)
plot_top_n <- function(df, var_type = A, n = 20) {
  
  # 1) Seleziono solo il tipo di varianza desiderato
  df_sel <- df %>%
    select(Feature, all_of(var_type)) %>%
    rename(Valore = all_of(var_type))
  
  # 2) Prendo le top-n feature per quel tipo
  top_feats <- df_sel %>%
    slice_max(order_by = Valore, n = n)
  
  # 3) Ordino le feature per plotting
  top_feats <- top_feats %>%
    arrange(Valore) %>%
    mutate(Feature = factor(Feature, levels = Feature))
  
  # 4) Plot
  ggplot(top_feats, aes(x = Valore, y = Feature)) +
    geom_col(fill = "steelblue") +
    labs(
      x = paste("Varianza inter‑scenario di", var_type),
      y = NULL,
      title = paste("Top", n, "feature per", var_type)
    ) +
    theme_minimal() +
    theme(axis.text.y = element_text(size = 8))
}

plot_top_n <- function(df,
                       var_type = "Var_Mediana",
                       n = 20,
                       label_size = 12,
                       axis_title_size = 14,
                       title_size = 16) {
  if (! var_type %in% names(df)) {
    stop("var_type deve essere uno tra: ", paste(names(df)[-1], collapse = ", "))
  }
  
  df_sel <- df %>%
    select(Feature, all_of(var_type)) %>%
    rename(Valore = all_of(var_type))
  
  top_feats <- df_sel %>%
    slice_max(order_by = Valore, n = n) %>%
    arrange(Valore) %>%
    mutate(Feature = factor(Feature, levels = Feature))
  
  ggplot(top_feats, aes(x = Valore, y = Feature)) +
    geom_col(fill = "steelblue") +
    labs(
      x     = expression(sigma["cross-scenario"]^2),
      y     = NULL,
      title = paste()
    ) +
    theme_minimal() +
    theme(
      axis.text.y   = element_text(size = label_size),
      axis.title.x  = element_text(size = axis_title_size),
      plot.title    = element_text(size = title_size)
    )
}