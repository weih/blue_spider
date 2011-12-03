#!/usr/bin/ruby -w
# -*- codeing: utf-8 -*-

require 'net/http'
require 'uri'
#require 'profiler'

#Profiler__.start_profile

#PAGE = ARGV
PROXY_ADDR = '127.0.0.1'
PROXY_PORT = 8087
TARGET_HOST = 'sakura99.com'
TARGET_URI = '/alabout/index.php?do=index&class_id=001&page='#.concat PAGE[0]
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
    return if the_image.nil?
    filename = %r(.*\/(.*.jpg)).match the_image
    File.open(IMAGE_DIR + $1,  "w+") do |f|
      f.write(Net::HTTP.get_response(URI.parse(the_image)).body)
    end
  rescue Timeout::Error
    retry
  rescue TypeError
    #p 'can\'t find the name ' + the_image
  end
end

def join_all
  main = Thread.main
  current = Thread.current
  all = Thread.list
  all.each { |t| t.join unless t == current or t == main }
end

# main phrase
def sakura
  
  all_image = []

  Dir.mkdir(IMAGE_DIR) if !File.exist?(IMAGE_DIR)
  (1..3).each do |iter|
    res = Net::HTTP.start(TARGET_HOST) do |http|
      #begin
        http.get(TARGET_URI + iter.to_s).body.scan(IMG_REGEX_SAKURA).each do |item|
            all_image << item[0]
        end
    end
  end
  
  #p all_image

  all_image.each do |item|
    Thread.new {
      get_image(item)
      #item
      #p 'Done ' + item if !item.nil?
      #Thread.current.exit
    }  
  end

  join_all

end

sakura

TARGET_HOST_2 = 'www.beautyleg.cc'
BEAUTY_LEG = '/new/2011-09-12-No-581-Jill-70P'
BEAUTY_REGEX = %r(.*-(No.*)(\d\d\d?)P)
BIG_IMAGE_REGEX = %r(<a href="(.*)" class="g-fullsize-link")

def beauty
  images = []
  
  Net::HTTP.start(TARGET_HOST_2) do |http|
    BEAUTY_REGEX.match(BEAUTY_LEG)
    photos = $2
    signal_image_uri = "/Beautyleg-" + $1
    #p signal_image_uri
    1.upto(10) do |image_iter|
      #Thread.new do
        signal_image_uri_with_index = signal_image_uri + "%04d" % image_iter.to_s
        BIG_IMAGE_REGEX.match(http.get(BEAUTY_LEG + signal_image_uri_with_index).body)
        #p $1
        images << TARGET_HOST_2 + $1
        #p http.get(BEAUTY_LEG + signal_image_uri_with_index).body
      #end
    end
    
    images.each_with_index do |iter, n|
      Thread.new do
        #p iter
        begin
          File.open(n.to_s + '.jpg', 'w') do |f|
            f.write(Net::HTTP.get_response(URI.parse("http://" + iter)).body)
          end
          p n.to_s + 'Done'
        rescue Timeout::Error
          retry
        end
      end
    end
    #p images
    #puts http.get(BEAUTY_LEG + "/Beautyleg-No-594-Jill-0001").body
    #File.open('img', 'w') do |f|
    #  f.write(http.get(BEAUTY_LEG).body)
    #end
  end
end

#beauty

#join_all

#loop {
  #Thread.list.each do |th|
  #  p th.value
  #end
  #break if Thread.list.size == 1
  #sleep 30
#}
#end

#p res.body