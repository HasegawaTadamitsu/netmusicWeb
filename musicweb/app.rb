# -*- coding: utf-8 -*-
require 'sinatra'
require 'sass'
require 'haml'
require './music.rb'

set :port, 4777

include Music

configure do
  musicの初期化
end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end

get '/' do
  playing_music =  再生中のfile名
  @message =(playing_music.nil?)?nil:"現在、'#{playing_music}'を再生中です"
  haml :index
end

get '/musicdata.json' do
  ret = 音楽file一覧JSON
  return ret
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
          %ul
            %li hoge
        .span10
          != yield

  
@@ index
:javascript
  $(function() {
    $("#music-tree").dynatree({  
      checkbox: true,  
      selectMode: 3,  
      initAjax: {
        url: "/musicdata.json"
      }
    });
  });

-#  body
.well
  %h2 music tree
  #music-tree

