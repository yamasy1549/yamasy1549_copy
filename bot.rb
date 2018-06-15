require 'dotenv'
require 'twitter'
require './markov'

class Bot
  def initialize
    setup_client
    @markov = Markov.new
  end

  def search(options, since_id = nil)
    options = {
      q: '',
      result_type: :'recent',
      include_entities: false
    }.merge(options)
    options[:since_id] = since_id if since_id

    @client.search(options[:q], options)
  end

  def tweet
    @client.update(generate_tweet)
  end

  def puts_tweet
    puts generate_tweet
  end

  private

  def generate_tweet
    bot_tweet = ''

    unless bot_tweet.tweetable?
      bot_tweet = @markov.generate
    end

    bot_tweet
  end

  def setup_client
    Dotenv.load

    @client = Twitter::REST::Client.new(
      consumer_key:        ENV['CONSUMER_KEY'],
      consumer_secret:     ENV['CONSUMER_SECRET'],
      access_token:        ENV['ACCESS_TOKEN'],
      access_token_secret: ENV['ACCESS_TOKEN_SECRET']
    )
  end
end

class String
  def tweetable?
    self.size > 15 && self.size < 140
  end
end
