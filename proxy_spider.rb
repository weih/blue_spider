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
TARGET_URI = '/alabout/index.php?do=index&class_id=001&page='.concat PAGE[0]
IMG_REGEX_SAKURA = %r(<a.*>(http:\/\/.*\.jpg)<\/a>)
IMG_REGEX_INNER = %r(img\sid="show_image".*src=\"(.*?)\")

res = Net::HTTP.start(TARGET_HOST) do |http|
  begin
    http.get(TARGET_URI).body.scan(IMG_REGEX_SAKURA).each do |item|
      #m = IMG_REGEX_SAKURA.match http.get(TARGET_URI).body
      #p 'item ' + item[0]
      #inner_addr = $1
      #p 'inner_addr ' + inner_addr
      imgchili_addr = Net::HTTP.get_response(URI.parse(item[0])).body
      imgchili_m = IMG_REGEX_INNER.match imgchili_addr
      the_image = $1
      p 'Done ' + the_image if !the_image.nil?
      filename = %r(.*\/(.*.jpg)).match the_image
      File.open($1,  "w+") do |f|
        f.write(Net::HTTP.get_response(URI.parse(the_image)).body)
        #Profiler__.print_profile(STDOUT)
      end
    end
  rescue
    next
  end
    #Profiler__.print_profile(STDOUT)
  #Net::HTTP.get_response(URI.parse(the_image)).body
end

#p res.body