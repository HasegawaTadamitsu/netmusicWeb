# -*- coding: utf-8 --*
require 'json'

class Dir
  def self.未存在なら作成する dirname
    # 作ろうとしたディレクトリがファイルだった場合、例外が発生する
    unless File.exist? dirname
      puts "create file #{dirname}"
      Dir.mkdir dirname
    end
    return true
  end

  def self.sorted_dir baseDir
    unsorted_dir = Array.new
    unsorted_file = Array.new
    Dir.foreach baseDir do |f|
      fullpath = baseDir + "/" + f
      unsorted_dir.push  fullpath if File.ftype(fullpath) == "directory"
      unsorted_file.push fullpath if File.ftype(fullpath) == "file"
    end
    sorted_dir  = unsorted_dir.sort
    sorted_file = unsorted_file.sort
    sorted = sorted_dir + sorted_file
    return sorted
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
    dirInfo = Array.new

    Dir.sorted_dir(baseDir).each do |fullPath|
      f = File.basename fullPath
      next if f == ".." or f == "."
      if File.extname( f ) == 拡張子
        info = {:isFolder=>false, :title =>f, :key => fullPath} 
        dirInfo.push info
        next
      end
      if File.ftype( fullPath ) =="directory"
        retInfo = {:isFolder => true, :title => f, :key => fullPath}
        child = ファイル一覧( fullPath, 拡張子) 
        unless child.empty?
          retInfo[:children] = child
        end
        dirInfo.push retInfo
        next
      end
      puts "unknown file #{f}"
    end
    return dirInfo
  end

  def self.dirnameの配列にする path
    dirname = File.dirname path
    ret = dirname.split "/"
    return ret
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
  end

  def 音楽file一覧JSON
    @music_library_files = File.ファイル一覧 MUSIC_LIBRARY_DIR,".mp3"
p @music_library_files


#    a=[{:key=>"item1","title"=>"item 1"},
#       {"key"=>"item2","title"=>"item 2","isFolder"=>true,
#        "children"=>[{"key"=>"item3","title"=>"item 3"},
#                     {"key"=>"item3","title"=>"item 3"}]
#       },
#      ]

    return   JSON.generate @music_library_files
  end


  def 再生中のfile名
    playing_music = File.read( NOW_PLAYING_FILE ).chomp
    playing_music = nil if playing_music == ""
    return playing_music
  end

end


