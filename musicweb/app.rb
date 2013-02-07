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
  @message =(fileName.nil? or fileName == "")?
            "unknown music file.please reload and refresh.":
            "playing..#{fileName}"
  haml :message_block, :layout => false
end


post '/plays' do
  keys = params[:checked_key]
  args= {
    :keys    => keys,
    :shuffle => checkbox_post_value_to_boolean( params[:shuffle]) ,
    :loop    => checkbox_post_value_to_boolean( params[:loop] )
  }

  @@music.plays args
  fileName  = @@music.status
  @message = "play music.now #{fileName}"
  haml :message_block, :layout => false
end

get '/play_next' do
  ret = @@music.play_next
  unless ret
    @message = "stop music.play music."  
  else 
    fileName  = @@music.status
    @message = "playing ..#{fileName}"
  end

  haml :message_block, :layout => false
end

get '/play_previous' do
  ret = @@music.play_previous
  unless ret
    @message = "stop music.play music."  
  else 
    fileName  = @@music.status
    @message = "playing ..#{fileName}"
  end

  haml :message_block, :layout => false
end

get '/check_status' do
  fileName  = @@music.status
  @message =(fileName.nil? or fileName == "")?
            "stop music...wait your input.":
            "playing..#{fileName}"
  haml :message_block, :layout => false
end

get '/stop_all' do
  fileName  = @@music.stop
  @message = "stop all music"
  haml :message_block, :layout => false
end

private 
def checkbox_post_value_to_boolean  val
  return false if val.nil? 
  return true  if val == "on"
  return false
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

#tree_control
  position: fixed
  top: 10px
  right: 40px

#play_control
  position: fixed
  bottom: 10px
  right: 40px

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
                %a#lnk_stop_all{:href=>"#"} stop music and reset all
              .li 
                %a#lnk_refresh_tree{:href=>"#"} refresh tree
              .li 
                %a#lnk_check_status{:href=>"#"} check now playing music
        .span10
          != yield
          #page_bottom_id


      
@@ message_block
.alert.alert-block
  %button{:class=>"close","data-dismiss"=>"alert"} &times;
  %strong Message
  =@message
  
@@ index
:javascript
  $(function() {
    ajax_error = function(message,jqXHR,textStatus,errorThrown){
                 console.log(jqXHR);
                 console.log(textStatus);
                 console.log(errorThrown);
                 alert(message);
    };

    $("#lnk_stop_all").click( function(){
      $.ajax({
        url: '/stop_all',
        data: {},
        timeout: 1000,
        dataType: 'html',
        cache: false,
        error: function(jqXHR,textStatus,errorThrown){
                 ajax_error("can not stop music.please retry.",
                            jqXHR,textStatus,errorThrown);
               },
        success: function(data,textStatus,jqXHR){
                 $("#message").html(data);
               },
      });
    });

    $("#lnk_refresh_tree").click( function(){
      $.ajax({
        url: '/refresh_tree',
        data: {},
        timeout: 1000,
        dataType: 'html',
        cache: false,
        error: function(jqXHR,textStatus,errorThrown){
                 console.log(jqXHR);
                 console.log(textStatus);
                 console.log(errorThrown);
                 alert("can not refresh tree.please retry.");
               },
        success: function(data,textStatus,jqXHR){
                 $("#message").html(data);
               },
      });
    });

    $("#lnk_check_status").click( function(){
      $.ajax({
        url: '/check_status',
        data: {},
        timeout: 1000,
        dataType: 'html',
        cache: false,
        error: function(jqXHR,textStatus,errorThrown){
                 ajax_error("can not get status.please retry.",
                            jqXHR,textStatus,errorThrown);
               },
        success: function(data,textStatus,jqXHR){
                 $("#message").html(data);
               },
      });
    });

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
                 ajax_error("can not play mp3.please retry.",
                            jqXHR,textStatus,errorThrown);
               },
        success: function(data,textStatus,jqXHR){
                 $("#message").html(data);
               },
      });
 
    };

    setup_tree = function(){
      $("#music_tree").null;
      $("#music_tree").dynatree({  
        checkbox: true,  
        selectMode: 3,  
        initAjax: {
          url: "/musicdata.json"
        },
        onDblClick: click_mp3,
      });
    };
    setup_tree();

    $("#btn_to_top").click( function(){
      location.href="#message";
    });
    $("#btn_toggle_expand_tree").click( function(){
      var rootNode = $("#music_tree").dynatree("getRoot");
      rootNode.visit( function(node){
          node.toggleExpand()
        });
    });
    $("#btn_expand_all_tree").click( function(){
      var rootNode = $("#music_tree").dynatree("getRoot");
      rootNode.visit( function(node){
          node.expand(true)
        });
    });
    $("#btn_unexpand_all_tree").click( function(){
      var rootNode = $("#music_tree").dynatree("getRoot");
      rootNode.visit( function(node){
          node.expand(false)
        });
    });
    $("#btn_to_bottom").click( function(){
      location.href="#page_bottom_id";
    });

    music_form_submit = function() {
      // append tree checked data
      var tree = $("#music_tree").dynatree("getTree");

      var checked_tree_data = tree.serializeArray();
      if ( checked_tree_data.length == 0){
        alert("please checke tree.");
        return false;
      }

      var post_tree_data = new Array();       
      for ( var i = 0 ; i < checked_tree_data.length; i++){
        var value =   checked_tree_data[i]['value'];
        if (value == null)  continue;
        post_tree_data.push(value);
      }

      // Serialize standard form fields:
      var formData = $("#music_form").serializeArray();
      formData.push({'name':'checked_key','value':post_tree_data});  

      $.ajax({
        type: "POST",
        url: '/plays',
        data: formData,
        timeout: 1000,
        dataType: 'html',
        cache: false,
        error: function(jqXHR,textStatus,errorThrown){
                 ajax_error("can not stop music.please retry.",
                            jqXHR,textStatus,errorThrown);
               },
        success: function(data,textStatus,jqXHR){
                 $("#message").html(data);
               },
           });
      return false;
    };

    click_play_next_or_previous = function(url){
      $.ajax({
        type: "GET",
        url: url,
        timeout: 2000,
        dataType: 'html',
        cache: false,
        error: function(jqXHR,textStatus,errorThrown){
                 ajax_error("can not play next/previous music.please retry.",
                            jqXHR,textStatus,errorThrown);
               },
        success: function(data,textStatus,jqXHR){
                 $("#message").html(data);
               },
      });
      return false;
    };

    $("#btn_play").click( function(){
      music_form_submit();
      return false;
    });

    $("#btn_play_next").click( function(){
      click_play_next_or_previous('/play_next');
      return false;
    });

    $("#btn_play_previous").click( function(){
      click_play_next_or_previous('/play_previous');
      return false;
    });

  });

-#  body
#tree_control
  .btn-group
    %button#btn_to_top.btn.btn-primary ↑
    %button#btn_toggle_expand_tree.btn.btn-primary toggle
    %button#btn_expand_all_tree.btn.btn-primary expand
    %button#btn_unexpand_all_tree.btn.btn-primary unexpand
    %button#btn_to_bottom.btn.btn-primary ↓


.well.row.show-grid
  .span10
    %h2 music tree
  .row
    .span12
      %form#music_form
        #music_tree
        #play_control
          .btn-group
            %button#btn_play_previous.btn.btn-primary ｜＜
            %button#btn_play.btn.btn-primary △
            %button#btn_play_next.btn.btn-primary ＞｜
          .btn-group
            %label.btn.btn-primary
              %input{:type=>"checkbox", :name=>"shuffle", :checked=>"checked"}
              shuffle
            %label.btn.btn-primary
              %input{:type=>"checkbox", :name=>"loop",:checked=>"checked"}
              loop

