library(DBI)
library(RSQLite)

# https://github.com/ankidroid/Anki-Android/wiki/Database-Structure
load_deck = function(deck) {
  if (!file.exists(load_deck)) stop("No such file: ", deck)

  zip_bits = as.raw(c(0x50, 0x4b, 0x03, 0x04))
  # unzipped input deck
  if (all.equal(readBin(deck, raw(), 4L), zip_bits)) {
    tdir = file.path(tempdir(), 'anki_db')
    unzip(deck, exdir = tdir)

    card_db = dbConnect(SQLite(), file.path(tdir, 'collection.anki2'))

    deck = list()
    deck$notes = dbGetQuery(card_db, 'select * from notes')
    deck$cards = dbGetQuery(card_db, 'select * from cards')

    deck$media = jsonlite::read_json(file.path(tdir, 'media'))

    return(deck)
  }
}

# structure: {file_name_in_tdir: file_name_in_notes}
#  e.g. for Spoonfed Chinese, we have note:
#  * id = 1419644215422
#  * flds = He's really strong.\037Tā hěn yǒu lìqi.\037他很有力气。\037[sound:tmpya8w0u.mp3]
# The sound field is [sound:tmpya8w0u.mp3]
# We search media JSON file for tmpya8w0u.mp3 and find:
#   {..., "8004": "tmpya8w0u.mp3", ...}
# So we can play this sound file as:
#   afplay tdir/8004

media = data.table(
  id = names(media),
  file = unlist(media)
)

notes[ , c('english', 'pinyin', '中文', 'sound_tag') := tstrsplit(flds, '\037')]
notes[ , sound_file := gsub('^\\[sound:(.*)\\]$', '\\1', sound_tag)]
notes[media, on = c('sound_file' = 'file'), media_id := i.id]
