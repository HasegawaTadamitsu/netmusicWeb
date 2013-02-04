class Player

  def initialize
    @file = ""
    @pin_1, @pout_1 = IO.pipe
    @pin_2, @pout_2 = IO.pipe
  end

  def execute
    execute_command( "-msglevel","all=0:cplayer=4",
                     "-playlist","/tmp/music/play_list.txt")
    polling_filename
    
    loop do
      sleep 2
      p @file
      send_command ">"
    end
  end

private
  def send_command cmd
    return false if @pout_2.closed?
    @pout_2.write cmd
    return true
  end

  def polling_filename
    Thread.fork do
      loop do
        sleep 1
        if @pin_1.closed?
           @file = ""
           next
        end
        data = @pin_1.gets
        if data =~ /^Playing /
          @file = data
        end
        next
      end
    end
  end

  def execute_command *options
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

end

player=Player.new
player.execute
