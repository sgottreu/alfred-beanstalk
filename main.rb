#!/usr/bin/env ruby
# encoding: utf-8

($LOAD_PATH << File.expand_path("..", __FILE__)).uniq!

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require "bundler/setup"
require "alfred"
require "net/http"
require 'json'

Alfred.with_friendly_error do |alfred|

  # prepend ! in query to refresh
  is_refresh = false

  

  if ARGV[0].start_with? '!'
    is_refresh = true
    ARGV[0] = ARGV[0].gsub(/!/, '')
  end

  flag = false

  if ARGV[0].end_with? ' -r'
    flag = 'r'
    ARGV[0] = ARGV[0].gsub(/ \-r/, '')
  elsif ARGV[0].end_with? ' -d'
    flag = 'd'
    ARGV[0] = ARGV[0].gsub(/ \-d/, '')
  else
    flag = false
  end

  # contants

  QUERY = ARGV[0]
  BEANSTALK_USERNAME = ARGV[1]
  BEANSTALK_PASSWORD = ARGV[2]
  BEANSTALK_EMAIL = ARGV[3]
  BEANSTALK_COMPANY_URL = ARGV[4]

  def get_repository_json(page)
    # setup URI
    uri = URI("https://#{BEANSTALK_COMPANY_URL}.beanstalkapp.com/api/repositories.json?per_page=50&page=#{page}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    # setup request
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(BEANSTALK_USERNAME, BEANSTALK_PASSWORD)
    request["User-Agent"] = "Alfred App (scott.gottreu@warrendouglas.com)"

    # make request
    response = http.request(request)

    JSON.parse(response.body)
  end

  def load_projects(alfred, flag)
    fb = alfred.feedback

    for page in 1..100

      repositories = get_repository_json(page)

      break if repositories.count == 0

      repositories.each do |repo|

        json = {"repo" => repo["repository"]["name"], "url" => BEANSTALK_COMPANY_URL, "flag" => flag }

        fb.add_item({
          :uid => repo["repository"]["id"],
          :title => repo["repository"]["title"],
          :subtitle => "https://"+BEANSTALK_COMPANY_URL+".beanstalkapp.com/"+repo["repository"]["name"],
          :arg => BEANSTALK_COMPANY_URL+':'+repo["repository"]["name"],
          :autocomplete => repo["repository"]["name"],
          :valid => "yes"
        })
      end

    end
    fb
  end

  alfred.with_rescue_feedback = true
  alfred.with_cached_feedback do
    use_cache_file :expire => 86400
  end

  if !is_refresh and fb = alfred.feedback.get_cached_feedback
    # cached feedback is valid
    puts fb.to_alfred(ARGV[0])
  else
    fb = load_projects(alfred, flag)
    fb.put_cached_feedback
    puts fb.to_alfred(ARGV[0])
  end
end



