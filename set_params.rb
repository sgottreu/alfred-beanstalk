#!/usr/bin/env ruby
# encoding: utf-8

($LOAD_PATH << File.expand_path("..", __FILE__)).uniq!

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require "bundler/setup"
require "alfred"
require "net/http"
require 'json'

Alfred.with_friendly_error do |alfred|

  arr = ARGV[0].split(":")

  company = arr[0]
  repo = arr[1]
  flag = (arr[2].nil?) ? false : arr[2]

  # Save settings
  alfred.setting.dump({ "beanstalkapp_company", company })
  alfred.setting.dump({ "beanstalkapp_repo", repo })

  # if flag == 'r'
  #   link = "https://"+company+".beanstalkapp.com/"+repo+'/code_reviews/branches'
  # elsif flag == 'd'
  #   link = "https://"+company+".beanstalkapp.com/"+repo+'/environments'
  # else
  #   link = "https://"+company+".beanstalkapp.com/"+repo
  # end
 
  puts "#{repo}"

end