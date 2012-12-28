netmusicWeb
===========

netmusic for web interface


このプロジェクトはなに？
-----------------------

darkice を使ってイントラネット内でのいわゆるインターネットラジオは
構築することができました。
で、次のステップとして、
　任意の曲をwebから選択したい。
　場合によってはラジオを選択したい。
とあります。

とどのつまり、webより、聞きたい音楽を選択し、
mplayer→pulseaudio→darkice→icecast
でイントラネット内でのストリーミングを実現し、
・sshを使って、外部から携帯で音楽を聞く。
・古いandroid携帯で受信し？ステレオからmuicboxで選択した曲を流す
など、夢が広がります。

mplayer以降の設定は、
https://www.haselab.com/mymemo/cgi/wiki.fcgi?page=networkMusic%B7%D7%B2%E8
に概略がまとめてあります。

このプロジェクトは、webベースで、曲の選択、ラジオの選択で、
mplayerを起動するまでをゴールとしてます。

要件定義(笑）
-------------

仕事用語ですがなにか。それは置いておいて、
以下の様な環境を想定します。

* とあるディレクトリに、ジャンル/アーティスト/アルバム/*.mp3 
  の様な感じにmp3が保管されている。
* とあるディレクトリは一つ。
* アーティスト単位,アルバム単位で複数選択でき、その単位で、プレイリストを
　作成する。
* ラジオは受信可能な放送局をプルダウンで選択し、外部コマンドを起動する。
* WEB上に今、再生中のプレイリストの概略を表示する。
　かならずしも再生中の曲である必要はない。
* ロックを考慮しない。イントラネットで使う。使うのは私一人。家族が操作してもすぐわかる。認証も実装しない。


想定環境
-------

* FreeBSD 8.2（古いけど。。あまり関係ない）
* MPlayer  MPlayer SVN-r34821-snapshot-4.2.1
* ruby 1.9.x? + sinatra + HAML + bootstrap + jquery?..



納期
------

2013年中に完成予定。


工数について
-------

* 基本設計　∞人月
* 詳細設計　∞人月
* PG　　　　∞人月
* PT/IT/ST



さぁプログラミングを楽しもう!巧ご期待（え？）
--------------------------------------------

