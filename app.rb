require 'toc'
require 'taglib'
require 'audite'
require 'curses'

def change_option(key, val)
  puts "\nCurrent #{key}:".bold.black.underline + " " + val.to_s.bold.red
  puts "Type the new #{key} or press Enter to leave as it is:"
end

def convert_to_minutes(length)
  minutes = (length / 60).floor
  seconds = length - (minutes * 60)

  return seconds < 10 ? [minutes, "0#{seconds}"] : [minutes, seconds]
end

def play_song(path, tag)
  player = Audite.new

  player.events.on(:position_change) do |pos|
    p = (player.tell / player.length * Curses.cols).ceil
    l = (player.level * Curses.cols).ceil
    current_time = convert_to_minutes(player.position.ceil)
    total_time = convert_to_minutes(player.length_in_seconds.ceil)
    time = "#{current_time[0]}:#{current_time[1]} // #{total_time[0]}:#{total_time[1]}"
    Curses.setpos(0, 0)
    Curses.addstr("#{tag.title}  --  #{time}")
    Curses.setpos(1, 0)
    Curses.addstr("#" * p + " " * (Curses.cols - p))
    Curses.setpos(2, 0)
    Curses.addstr(">" * l + " " * (Curses.cols - l))
    Curses.refresh
  end

  player.events.on(:complete) do
    player.close
  end

  player.load(path)
  player.start_stream

  while c = Curses.getch
    case c
    when Curses::KEY_LEFT
      player.rewind
    when Curses::KEY_RIGHT
      player.forward
    when ' '
      player.toggle
    end
  end

  player.thread.join
end

puts "Drag and drop the file into this window: "
filepath = gets.chomp.gsub('\\', '')

# Remove last character from file path if its a space
filepath = filepath[0...-1] if filepath[-1, 1] == ' '

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
  tag.year = new_year.to_i if !new_year.empty?

  file.save
  puts "File saved!".green.bold

  puts "Do you want to play the song?"
  puts " 1) Yes"
  puts " 2) No"
  play_song = gets.chomp

  play_song(filepath, tag) if play_song == '1'
end
