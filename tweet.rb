#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-
# ツイート関連をまとめるクラス

require 'twitter'
require 'pp'
require './io.rb'

class Tweet

  def initialize tokens,files_path,debug = true
    # initialize で認証。
    # デバッグフラグもここで付ける。念のためデフォルトはtrue
    Twitter.configure do |config|
      config.consumer_key = tokens["consumer_key"]
      config.consumer_secret = tokens["consumer_secret"]
      config.oauth_token = tokens["oauth_token"]
      config.oauth_token_secret = tokens["oauth_token_secret"]
    end
    @debug = debug
    @io = File_io.new files_path
  end

  def tweet_reply tweet,num
    # num に応じてリプライをツイートする
    
    options = get_reply_options tweet

    case num
    when -1
      # 追加する
      @io.add_tweet tweet,@debug   # 追加する
      post "@#{tweet.user.screen_name} #{@io.add_replys.sample}",options
    when -2
      # 複数行の場合
      post "@#{tweet.user.screen_name} #{@io.multiline_replys.sample}",options
    when -3 
      # フォーマットが違う場合
      post "@#{tweet.user.screen_name} #{@io.illigal_replys.sample}",options
    when 15
      # 15個の場合。ngskbotであれば最大数。
      post "@#{tweet.user.screen_name} 何ですか。暇なんですか。",options
    else
      # 通常リプライ。
      # bot_nameが含まれていない場合はnumが0になるので結果的にリプライしない
      # bot_nameが含まれている数だけつぶやく
      num.times do
        post "@#{tweet.user.screen_name} #{@io.normal_replys.sample}",options
      end
    end
  end

  private

  def post message,options={}
    # ポストする

    if @debug
      # デバッグモード時。内容の確認のみ。
      puts 
      puts "----- (debug mode : check tweet ) ------"
      puts "ポスト予定の内容"
      puts message
      pp options
      puts "---- (debug mode : check tweet end ) ----"
      puts
    else
      # ポストする
      # errorが起きると落ちちゃうので、begin-rescue-endでゴリ押し。
      # contents duplicate 対策。
      begin
        Twitter.update message,options
      rescue
      end
    end
  end

  def get_reply_options tweet
    # tweet から、それに対するreplyに必要なoptionを取得する
    # 具体的には in_reply_to_status_id に必要なidを取ってくる

    {"in_reply_to_status_id"=>tweet.id}
  end

end
