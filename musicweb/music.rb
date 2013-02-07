# -*- coding: utf-8 --*
require 'json'

require './util.rb'
require './player.rb'

class Music

  BASE_MUSIC_FILE_DIR="/tmp/music"
  PLAY_LIST_FILE="#{BASE_MUSIC_FILE_DIR}/play_list.txt"
  MUSIC_LIBRARY_DIR="/mnt/media/minidlna/music"

  def initialize
    Dir.未存在なら作成する  BASE_MUSIC_FILE_DIR
    @player = Player.new
    @music_library_files,@key2path =
                    File.ファイル一覧( MUSIC_LIBRARY_DIR,".mp3")
    @play_list = PlayList.new PLAY_LIST_FILE,@key2path
  end

  def library_json
    return JSON.generate @music_library_files
  end

  def playing_name
    file = @player.file
    return nil if file == ""
    return File.basename file
  end

  def play_mp3 key
    @player.play @key2path[key]
    return  @player.file
  end

  def status
    file = @player.file
  end

  def stop
    @player.stop
  end

  def plays args
    @play_list.create_play_list args[:keys]
    @player.loop_flag    = args[:loop]
    @player.shuffle_flag = args[:shuffle]
    @player.play_playlist PLAY_LIST_FILE
  end

  def play_next
    return @player.next
  end

  def play_previous
    return @player.previous
  end

private

end


