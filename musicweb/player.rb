# -*- coding: utf-8 --*
require 'json'
require 'open3'
require './util.rb'

class Player
  MPLAYER="/usr/bin/mplayer"
  MPLAYER_DEFULT_OPTION =["-msglevel","all=0:cplayer=4"]

  attr_accessor :shuffle_flag, :loop_flag
  attr_reader   :pid,:file
  

  def initialize
    @lock = Mutex.new
    @file = ""
    polling_filename
  end

  def play filename
    ret = kill_and_anything  do
      execute_mplay_mp3 filename
    end
    return ret
  end

  def play_playlist playlist_file
    ret = kill_and_anything  do
      execute_mplay_mp3("-playlist","#{playlist_file}")
    end
    return ret
  end

  def stop
    ret = kill_and_anything  do
      nil
    end
    return ret
  end

  def next
    ret = lock_and_update_state do
      send_command ">"
    end
    return ret 
  end

  def previous
    ret = lock_and_update_state do
      send_command "<"
    end
    return ret 
  end

  def update
    ret = lock_and_update_state do
      nil
    end
    return ret
  end

private

  def lock_and_update_state  &anything
    @lock.synchronize do
      return false unless update_status
      return false unless anything.call()
      return false unless update_filename
      return true
    end
  end

  def kill_and_anything  &anything
    @lock.synchronize do
      kill_player @pid
      @pid = anything.call()
      return false unless update_filename
      return true
    end
  end

  def send_command cmd
    return false if @pid == 0 or @pout_2.nil? or @pout_2.closed?
    @pout_2.write cmd
    return true
  end

  def polling_filename
    Thread.fork do
      loop do
        sleep 1
        @lock.synchronize do
          check_filename
        end 
      end # loop
    end # thread
  end

  def update_filename
    update_status
    if @pid == 0
      @file = ""
      return false
    end
    30.times do
      data = read_stdin
      break if data.nil?
      if data =~ /^Playing /
        @file = data
        return true
      end
    end
    return false
  end

  def read_stdin
    if @pid == 0 or @pin_1.nil? or @pin_1.closed?
      return nil
    end
    begin
      data = timeout 1 do
        @pin_1.gets
      end
    rescue Timeout::Error
      return nil
    end
    return data
  end

  def update_status
    unless exist_player? @pid
      @pid = 0
      @file= ""
      return false
    end
    return true
  end

  def kill_player pid
    if pid.nil? or pid == 0 or pid == ""
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
    new_options = options + MPLAYER_DEFULT_OPTION 
    new_options.concat(["-loop","0"]) if @loop_flag
    new_options.push "-shuffle"       if @shuffle_flag

    pid = fork do
      unless_closed_close @pin_1
      unless_closed_close @pout_2

      unless @pin_2.closed?
       STDIN.reopen (@pin_2)
      end
      unless @pout_1.closed?
        STDOUT.reopen (@pout_1)
      end
      exec( "mplayer",*new_options)
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
    return false if pid.nil? or pid == 0 or pid == ""
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
