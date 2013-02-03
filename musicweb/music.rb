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

  def initialize
    @lock = Mutex.new
    @pin_1, @pout_1 = IO.pipe
    @pin_2, @pout_2 = IO.pipe
  end

  def pid
    @lock.synchronize do
      update_status
      return @pid
    end
  end

  def file
    @lock.synchronize do
      update_status
      return @file
    end
  end

  def play
    @lock.synchronize do
      kill_player @pid
      @pid = execute_mplay_mp3 @file
    end
  end

  def play_playlist playlist_file
    @lock.synchronize do
      kill_player @pid
      @file=""
      @pid = execute_mplay_mp3( "-playlist","#{playlist_file}")
    end
  end

  def stop
    @lock.synchronize do
      kill_player @pid
      update_status
    end
  end

private
  def update_status
    unless exist_player? @pid
      @pid = 0
      @file= ""
      return true
    end
    return false
  end

  def kill_player pid
    if pid.nil? or pid == 0
      return 
    end
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

  def execute_mplay_mp3 *options
p options
    pid = fork do
      unless_closed_close @pin_1
      unless_closed_close @pout_2
      unless @pin_2.closed?
        STDIN.reopen (@pin_2)
      end
      unless @pout_1.closed?
        STDOUT.reopen (@pout_1)
      end

      exec( "mplayer",*options)
      sleep 1
    end
    unless_closed_close @pin_2
    unless_closed_close @pout_1
    return pid
  end

  def unless_closed_close io
    unless io.closed?
      io.close
    end
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


class PlayList
  def initialize arg_file_name,arg_keys2path
    @file_name = arg_file_name
    @keys2path = arg_keys2path
  end

  def create_play_list keys
    File.open( @file_name,"w") do |file|
      keys.split(/\s*,\s*/).each do |key|
        path = @keys2path[key]
        file.puts "#{path}\n"
      end
    end
  end

end

class Music

  BASE_MUSIC_FILE_DIR="/tmp/music"
  PLAY_LIST_FILE="#{BASE_MUSIC_FILE_DIR}/play_list.txt"
  MUSIC_LIBRARY_DIR="/mnt/media/minidlna/music"

  def initialize
    Dir.未存在なら作成する  BASE_MUSIC_FILE_DIR
    @player = Player.new
    load_library
    @play_list = PlayList.new PLAY_LIST_FILE,@key2path
  end

  def load_library
    @music_library_files,@key2path =
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

  def stop
    @player.stop
  end

  def plays args
    @play_list.create_play_list args[:keys]
    @player.play_playlist PLAY_LIST_FILE
  end
end


