# -*- coding: utf-8 -*-
require './music.rb'

describe "Player" do
  it "init" do
    `/bin/rm -rf /tmp/hoge 2>&1`
   `/bin/mkdir /tmp/hoge 2>&1`
    player = Player.new
    player.pid.should == nil
  end

  it "ダミーの音楽の再生" do
    `/bin/mkdir /tmp/hoge > /dev/null 2>&1`
    player = Player.new
    player.pid.should == nil
    sample_mp3 = 
      "/home/hasegawa/work/Dropbox/work/netmusicWeb/archive/sample.mp3"
    player.play sample_mp3
    pid = player.pid
    pid.should_not == 0
    file = player.file
    file.should == sample_mp3

    player.stop
    pid = player.pid
    pid.should == 0
    file = player.file
    file.should == ""
  end    

end

