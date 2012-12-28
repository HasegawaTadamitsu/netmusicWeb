# -*- coding: utf-8 -*-
require 'sinatra'
require 'sass'
require 'haml'

set :port, 4777

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end

get '/' do
  @message = "hello"
  haml :index
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
    :href=>"./bootstrap/css/bootstrap-responsive.min.css"} |
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
    %script{:src => |
    'https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js'} |
    %script{:src => './bootstrap/js/bootstrap.min.js'}

  
@@ index
:javascript
  var string ='hello';
  window.alert(string);

-#  body
%ul
  %li hoge
