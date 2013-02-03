# -*- coding: utf-8 -*-
require './music.rb'

describe "Play_list" do

  it "play list をつくる時" do
    key2path = {"key1" => "path1",
      "key2" => "path2",
      "key3" => "path3",
      "key4" => "path4"}
    
   `/bin/mkdir /tmp/hoge 2>&1`
    player = Player.new "/tmp/hoge"
    player.pid.should == 0
  end

  it "ダミーの音楽の再生" do
    `/bin/mkdir /tmp/hoge > /dev/null 2>&1`
    player = Player.new "/tmp/hoge"
    player.pid.should == 0
    sample_mp3 = 
      "/home/hasegawa/work/Dropbox/work/netmusicWeb/archive/sample.mp3"
    player.file = sample_mp3
    player.play
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

