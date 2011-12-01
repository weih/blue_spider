#!/usr/bin/ruby -w
# -*- codeing: utf-8 -*-

require 'net/http'
require 'uri'
#require 'profiler'

#Profiler__.start_profile

PAGE = ARGV
PROXY_ADDR = '127.0.0.1'
PROXY_PORT = 8087
TARGET_HOST = 'sakura99.com'
target_uri = '/alabout/index.php?do=index&class_id=001&page='#.concat PAGE[0]
IMG_REGEX_SAKURA = %r(<a.*>(http:\/\/.*\.jpg)<\/a>)
IMG_REGEX_INNER = %r(img\sid="show_image".*src=\"(.*?)\")
IMAGE_DIR = 'img/'

Thread.abort_on_exception = true

def get_image(image_uri)
  #p item
  begin
    imgchili_addr = Net::HTTP.get_response(URI.parse(image_uri)).body
    #open_uri(URI.parse(item)) do |imgchili_addr|
    #p imgchili_addr
    imgchili_m = IMG_REGEX_INNER.match imgchili_addr
    #p imgchili_m
    the_image = $1
    filename = %r(.*\/(.*.jpg)).match the_image
    File.open(IMAGE_DIR + $1,  "w+") do |f|
      f.write(Net::HTTP.get_response(URI.parse(the_image)).body)
    end
  rescue Timeout::Error
    retry
  end
end

def join_all
  main = Thread.main
  current = Thread.current
  all = Thread.list
  all.each { |t| t.join unless t == current or t == main }
end

# main phrase

all_image = []

Dir.mkdir('img') if !File.exist?('img/')
(21..23).each do |iter|
  res = Net::HTTP.start(TARGET_HOST) do |http|
    #begin
      http.get(target_uri + iter.to_s).body.scan(IMG_REGEX_SAKURA).each do |item|
          all_image << item[0]
      end
  end
end

all_image.each do |item|
  Thread.new {
    get_image(item)
    #item
    #p 'Done ' + item if !item.nil?
    #Thread.current.exit
  }  
end

join_all

#loop {
  #Thread.list.each do |th|
  #  p th.value
  #end
  #break if Thread.list.size == 1
  #sleep 30
#}
#end

#p res.body