# https://github.com/ankidroid/Anki-Android/wiki/Database-Structure
load_deck = function(deck) {
  if (!file.exists(deck)) stop("No such file: ", deck)

  zip_bits = as.raw(c(0x50, 0x4b, 0x03, 0x04))
  # unzipped input deck
  if (!all.equal(readBin(deck, raw(), 4L), zip_bits))
    stop("Input should be an Anki deck, which is a zipped sqlite3 database")

  tdir = file.path(tempdir(), 'anki_db')
  unzip(deck, exdir = tdir)

  deck = list()
  class(deck) = 'anki'
  deck$db = dbConnect(SQLite(), file.path(tdir, 'collection.anki2'))
  deck$notes = setDT(dbGetQuery(deck$db, 'select * from notes'))
  deck$cards = setDT(dbGetQuery(deck$db, 'select * from cards'))

  media = read_json(file.path(tdir, 'media'))

  # structure: {file_name_in_tdir: file_name_in_notes}
  #  e.g. for Spoonfed Chinese, we have note:
  #  * id = 1419644215422
  #  * flds = He's really strong.\037Tā hěn yǒu lìqi.\037他很有力气。\037[sound:tmpya8w0u.mp3]
  # The sound field is [sound:tmpya8w0u.mp3]
  # We search media JSON file for tmpya8w0u.mp3 and find:
  #   {..., "8004": "tmpya8w0u.mp3", ...}
  # So we can play this sound file as:
  #   afplay tdir/8004
  deck$media = data.table(
    id = names(media),
    file = unlist(media)
  )

  return(deck)
}

# hok = load_deck('~/Downloads/Taiwanese_Hokkien__with_links_to_MOE_Dictionary_.apkg')
#
# notes[ , c('english', 'pinyin', '中文', 'sound_tag') := tstrsplit(flds, '\037')]
# notes[ , sound_file := gsub('^\\[sound:(.*)\\]$', '\\1', sound_tag)]
# notes[media, on = c('sound_file' = 'file'), media_id := i.id]
