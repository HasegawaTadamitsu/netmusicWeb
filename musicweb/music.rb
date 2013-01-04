# -*- coding: utf-8 --*
require 'json'
require 'digest/md5'
require 'open3'

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
    natural_sort = Proc.new do |a, b|
      cmp = a.gsub(/(\d+)/) {"%05d" % $1.to_i} <=>
            b.gsub(/(\d+)/) {"%05d" % $1.to_i}
            if cmp == 0
              a <=> b
            else
              cmp
            end
    end
    sorted_dir  = unsorted_dir.sort(&natural_sort)
    sorted_file = unsorted_file.sort(&natural_sort)
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

class Player
  MPLAYER="/usr/bin/mplayer"
  attr_writer :file

  def initialize base_file_dir
    @status_file = "#{base_file_dir}/playing_status.txt"
    read_status @status_file
    update_status
  end

  def pid
    update_status
    return @pid
  end

  def file
    update_status
    return @file
  end

  def play
    kill_player @pid
    @pid = execute_mplay_mp3 @file
    write_status @status_file
  end

  def stop
    kill_player @pid
    update_status
  end

  def update_status
    unless exist_player? @pid
      @pid = 0
      @file= ""
      write_status @status_file
      return true
    end
    return false
  end

private
  def write_status status_file
    File.open( status_file,"w" ) do | file |
      file.write "#{@pid}\n"
      file.write "#{@file}\n"
    end
  end

  def read_status status_file
    unless File.exist? status_file
      @pid = 0
      @file = ""
      write_status status_file
    end
    File.open( status_file ) do | file |
      pid = file.read
      @pid = pid.to_i
      file = file.read
      @file = file 
    end
  end

  def kill_player pid
    return if pid.nil? or pid == 0
    begin
      i_pid = pid.to_i
    rescue TypeError
      puts "can not convert pid #{pid}"
      return
    end
    begin
      Process.detach(i_pid)
      Process.kill('KILL',i_pid)
    rescue =>e
      puts e
    end
  end

  def execute_mplay_mp3 fileName
    pid = fork do
      exec "mplayer","#{fileName}"
    end
    return pid
  end

  def exist_player? pid
    return false if pid.nil? or pid == 0
    begin
      gstatus = Process.getpgid(pid)
    rescue Errno::ESRCH
      return false
    end
    return true
  end

end

class Music

  BASE_MUSIC_FILE_DIR="/tmp/music"
  NOW_PLAYING_FILE="#{BASE_MUSIC_FILE_DIR}/playing.txt"
  MUSIC_LIBRARY_DIR="/mnt/media/minidlna/music"

  def initialize
    Dir.未存在なら作成する  BASE_MUSIC_FILE_DIR
    File.未存在なら作成する NOW_PLAYING_FILE
    @player = Player.new  BASE_MUSIC_FILE_DIR
    load_library
  end

  def load_library
    @music_library_files,@keyInfo =
                    File.ファイル一覧( MUSIC_LIBRARY_DIR,".mp3")
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
    @player.file = @keyInfo[key]
    @player.play
    return  @player.file
  end

  def status
    file = @player.file
  end
end


