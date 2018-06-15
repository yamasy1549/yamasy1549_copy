require 'dotenv'
require './bot'

@bot = Bot.new
last_tweet = @bot.search({ q: "from:#{ENV['TARGET_USER']}", count: 1 })
since_id = last_tweet.first.id

loop do
  tweets = @bot.search({ q: "from:#{ENV['TARGET_USER']}" }, since_id)

  tweets.each do |tweet|
    @bot.tweet
    since_id = tweet.id
  end

  sleep 10
end
