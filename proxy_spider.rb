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
TARGET_URI = '/alabout/index.php?do=index&class_id=001&page=17'#.concat PAGE[0]
IMG_REGEX_SAKURA = %r(<a.*>(http:\/\/.*\.jpg)<\/a>)
IMG_REGEX_INNER = %r(img\sid="show_image".*src=\"(.*?)\")

def get_image(image_uri)
  #p item
  imgchili_addr = Net::HTTP.get_response(URI.parse(image_uri)).body
  #open_uri(URI.parse(item)) do |imgchili_addr|
  #p imgchili_addr
  imgchili_m = IMG_REGEX_INNER.match imgchili_addr
  #p imgchili_m
  the_image = $1
  filename = %r(.*\/(.*.jpg)).match the_image
  File.open($1,  "w+") do |f|
    f.write(Net::HTTP.get_response(URI.parse(the_image)).body)
  end
end

all_image = []

res = Net::HTTP.start(TARGET_HOST) do |http|
  #begin
    http.get(TARGET_URI).body.scan(IMG_REGEX_SAKURA).each do |item|
        all_image << item[0]
    end
end

all_image.each do |item|
  Thread.new {
    get_image(item)
    p 'Done ' + item if !item.nil?
    Thread.current.exit
  }  
end

loop {
  p Thread.list
  break if Thread.list.size == 1
  sleep 30
}
#end

#p res.body