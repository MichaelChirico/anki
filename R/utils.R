print.anki = function(x) {
  cat('Anki card deck with', nrow(x$notes), 'notes,',
      nrow(x$cards), 'cards, and', nrow(x$media), 'media files\n')
}
