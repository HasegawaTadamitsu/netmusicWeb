# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/reloader'
require 'sass'
require 'haml'
require './music.rb'

set :port, 4777

configure do
  @@music = Music.new
end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end

get '/' do
  playing_music =  @@music.playing_name
  @message =(playing_music.nil?)?nil:"現在、'#{playing_music}'を再生中です"
  haml :index
end

get '/musicdata.json' do
  ret = @@music.library_json
  return ret
end

get '/playmp3' do
  key = params[:key]
  redirect "/" if key.nil?
  fileName = @@music.play_mp3 key
  if fileName.nil? or fileName == ""
    @message = "unknown music file.please reload and refresh."
  else 
    @message ="playing #{fileName}"
  end
  haml :message_block, :layout => false
end

get '/check_status' do
  fileName  = @@music.status
  if fileName.nil? or fileName == ""
    @message = "stop music...wait your input."
  else 
    @message = "playing..#{fileName}"
  end
  haml :message_block, :layout => false
end

__END__

@@ style
h1
  margin-top: 1em
  font-size: 16px
  text-align: left

li
  font:
    size: 1em

contents
  margin: 2em,2em,2em,2em

@@ layout
!!! XML
!!! Strict

%html
  %head
    %title=@title 
    %meta{:"http-equiv"=>"Content-Type", :content=>"text/html", |
    :charset=>"utf-8"} |
    %link{:rel=>"stylesheet", :type=>"text/css", :href=>"/style.css"}
    %link{:rel=>"stylesheet", :type=>"text/css", |
    :href=>"./bootstrap/css/bootstrap.min.css"} 
    %link{:rel=>"stylesheet", :type=>"text/css", |
    :href=>"./bootstrap/css/bootstrap-responsive.min.css"} 
    %link{:rel=>"stylesheet", :type=>"text/css", |
    :href=>"./dynatree/skin-vista/ui.dynatree.css"} 

    %script{:src =>'https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js' } 
 
    %script{:src =>'https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js'} 
    %script{:src => './bootstrap/js/bootstrap.min.js'}
    %script{:src => './dynatree/jquery.dynatree.min.js'}


  %body
    .container-fluid
      .hero-unit
        %h1 netmusic web musicbox
        %a{:href=>"http://patrush-inside:8000/nm"}
          さぁ、音楽を再生しよう。URLはhttp://patrush-inside:8000/nm
      #message 
        - unless @message.nil? or @messge == ""
          .alert.alert-block
            %button{:class=>"close","data-dismiss"=>"alert"} &times;
            %strong Message
            =@message
      .row-fluid
        .span2
          -#  side
          .well
            %h2 Action
            .ul
              .li 
                %a{:href=>"#",:onClick=>""} stop music and reset all
              .li 
                %a{:href=>"#",:onClick=>""} refresh tree
              .li 
                %a{:href=>"#",:onClick=>"check_status()"}
                  check now playing music
        .span10
          != yield

@@ message_block
.alert.alert-block
  %button{:class=>"close","data-dismiss"=>"alert"} &times;
  %strong Message
  =@message
  
@@ index
:javascript
  $(function() {
    click_mp3 = function(a){
      key = a.data.key
      $.ajax({
        url: '/playmp3',
        data: {
          key: key
        },
        timeout: 10000,
        dataType: 'html',
        cache: false,
        error: function(jqXHR,textStatus,errorThrown){
                 console.log("XHR " + jqXHR);
                 console.log("textStatus " + textStatus);
                 console.log("throw " + errorThrown);
                 alert("can not play.please retry.");
               },
        success: function(data,textStatus,jqXHR){
                 $("#message").html(data);
               },
      });
 
    };
    check_status = function(){
      $.ajax({
        url: '/check_status',
        data: {},
        timeout: 1000,
        dataType: 'html',
        cache: false,
        error: function(jqXHR,textStatus,errorThrown){
                 console.log(jqXHR);
                 console.log(textStatus);
                 console.log(errorThrown);
                 alert("can not get status.please retry.");
               },
        success: function(data,textStatus,jqXHR){
                 $("#message").html(data);
               },
      });
    };

    setup_tree = function(){
      $("#music-tree").null;
      $("#music-tree").dynatree({  
        checkbox: true,  
        selectMode: 3,  
        initAjax: {
          url: "/musicdata.json"
        },
        onDblClick: click_mp3,
      });
    };
  setup_tree();
  });

-#  body
.well
  %h2 music tree
  #music-tree

