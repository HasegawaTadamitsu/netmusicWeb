# -*- coding: utf-8 --*
require 'json'
require 'digest/md5'

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
    key2path = Hash.new
    Dir.sorted_dir(baseDir).each do |fullPath|
      f = File.basename fullPath
      next if f == ".." or f == "."

      if File.extname( f ) == 拡張子
        key = Digest::MD5.new.update fullPath
        info = {:isFolder=>false, :title =>f, 
                :key => key}
        key2path[key.to_s] = fullPath
        dirInfo.push info
        next
      end

      if File.ftype( fullPath ) =="directory"
        retInfo = {:isFolder => true, :title => f, :key => key}
        key2path[key.to_s] = fullPath
        child,key2path_ret = ファイル一覧( fullPath, 拡張子)
        unless child.empty?
          retInfo[:children] = child
          key2path.merge! key2path_ret
        end
        dirInfo.push retInfo
        next
      end
      puts "unknown file #{f}"
    end
    return dirInfo,key2path
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
    init_playing_file
    音楽LIBRARYの読込
  end

  def 音楽LIBRARYの読込
    @@music_library_files,@@keyInfo =
                    File.ファイル一覧( MUSIC_LIBRARY_DIR,".mp3")
  end

  def 音楽file一覧JSON
    return   JSON.generate @@music_library_files
  end


  def init_playing_file
    File.未存在なら作成する NOW_PLAYING_FILE
  end

  def 再生中のfile名
    pid,key,mucis_name = playing_info
    music_name = nil if music_name == ""
    return music_name
  end

  def write_playing_file pid,key,music_name
     File.open( NOW_PLAYING_FILE,"w" ) do | file |
      file.write "#{pid},#{key},#{music_name}"
     end
  end

  def playing_info
    pid,key,music_name = File.read( NOW_PLAYING_FILE ).split(/\s*,\s*/)
    return pid,key,music_name
  end

  def exist_pid_player pid
    gstatus = Process.getpgid(pid) rescue nil
    p gstatus
  end

  def kill_music_player pid
    return if pid.nil?
    begin
      i_pid = pid.to_i
    rescue TypeError
      puts "can not convert pid #{pid}"
      return
    end
    begin
      Process.kill('KILL',i_pid)
    rescue =>e
      puts e
    end
  end

  def kill_and_play_mp3 key
    pid,a,b = playing_info
    kill_music_player pid
    filePath = @@keyInfo[key]
    pid = execute_mplay_mp3 filePath
    write_playing_file pid,key,filePath
    return filePath
  end

  def execute_mplay_mp3 path
    pid = fork do 
       exec "/usr/bin/mplayer", path
    end
  end
end


