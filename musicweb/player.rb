# -*- coding: utf-8 --*
require 'json'
require 'open3'

require './util.rb'

class Player
  MPLAYER="/usr/bin/mplayer"



  def initialize
    @lock = Mutex.new
    @pin_1, @pout_1 = IO.pipe
    @pin_2, @pout_2 = IO.pipe
    @file = ""
    polling_filename
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

  def play filename
    @lock.synchronize do
      kill_player @pid
      @file = filename
      @pid = execute_mplay_mp3 @file
    end
  end

  def play_playlist playlist_file
    @lock.synchronize do
      kill_player @pid
      @file=""
      @pid = execute_mplay_mp3("-msglevel","all=0:cplayer=4",
                               "-playlist","#{playlist_file}")
    end
  end

  def stop
    @lock.synchronize do
      kill_player @pid
      update_status
    end
  end

private
  def polling_filename
    Thread.fork do
      loop do
        sleep 1
        @lock.synchronize do
          update_status
          if @pid == 0
             @file = ""
             break
          end
          data = read_stdin
p data
          if data =~ /^Playing /
            @file = data
          end
        end
      end
    end
  end

  def read_stdin
    if @pid == 0 or @pin_1.closed?
      return ""
    end
    begin
      data = timeout 1 do
        @pin_1.gets
      end
    rescue Timeout::Error
    end
    return data
  end

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
    @pin_1, @pout_1 = IO.pipe
    @pin_2, @pout_2 = IO.pipe

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
