# -*- coding: utf-8 --*

class Dir
  def self.未存在なら作成する dirname
    # 作ろうとしたディレクトリがファイルだった場合、例外が発生する
    unless File.exist? dirname
      puts "create file #{dirname}"
      Dir.mkdir dirname
    end
    return true
  end
end

class File
  def self.未存在なら作成する filename
    unless File.exist? filename
      puts "create file #{filename}"
      File.open(filename,"w").close
    end
    return true
  end

  def self.ファイル一覧 baseDir,拡張子
    ret = Array.new
    ret.concat Dir.glob baseDir + "/**/*." + 拡張子
  end

end

#Encoding.default_internal = Encoding.default_external = "UTF-8"

module Music

  BASE_MUSIC_FILE_DIR="/tmp/music"
  NOW_PLAYING_FILE="#{BASE_MUSIC_FILE_DIR}/playing.txt"
  MUSIC_LIBRARY_DIR="/mnt/media/minidlna/music"
  

  def musicの初期化
    Dir.未存在なら作成する  BASE_MUSIC_FILE_DIR
    File.未存在なら作成する NOW_PLAYING_FILE
    音楽LIBRARYの読込
  end

  def 音楽LIBRARYの読込
    @music_library_files = File.ファイル一覧 MUSIC_LIBRARY_DIR,"[mM][pP]3"
  end

  def 再生中のfile名
    playing_music = File.read( NOW_PLAYING_FILE ).chomp
    playing_music = nil if playing_music == ""
    return playing_music
  end

end


