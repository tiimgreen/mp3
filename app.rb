require 'toc'
require 'taglib'

def change_option(key, val)
  puts "\nCurrent #{key}:".bold.black.underline + " " + val.to_s.bold.red
  puts "Type the new #{key} or press Enter to leave as it is:"
end

puts "Drag and drop the file into this window: "
filepath = gets.chomp.gsub('\\', '')

if filepath[-1, 1] == ' '
  filepath = filepath[0...-1]
end

TagLib::MPEG::File.open(filepath) do |file|
  tag = file.id3v2_tag

  change_option 'title', tag.title
  new_title = gets.chomp
  tag.title = new_title if !new_title.empty?

  change_option 'artist', tag.artist
  new_artist = gets.chomp
  tag.artist = new_artist if !new_artist.empty?

  change_option 'album', tag.album
  new_album = gets.chomp
  tag.album = new_album if !new_album.empty?

  change_option 'genre', tag.genre
  new_genre = gets.chomp
  tag.genre = new_genre if !new_genre.empty?

  change_option 'year', tag.year
  new_year = gets.chomp
  tag.year = new_year if !new_year.empty?

  file.save
  puts "File saved!".green.bold
end
