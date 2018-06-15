require 'csv'
require 'MeCab'

class Markov
  NONWORD = "\n"

  def initialize(filename = './tweets.csv', n = 3)
    @filename = filename
    @tagger = MeCab::Tagger.new('-Owakati')
    @markov_data = {}

    setup_data(n)
  end

  def generate
    generated_text = ''
    prefix = [NONWORD, NONWORD]

    loop do
      suffixes = @markov_data[prefix]
      break if suffixes.nil? || suffixes.last == NONWORD

      suffix = suffixes[rand(suffixes.size)]
      generated_text << suffix

      prefix = [prefix[-1], suffix]
    end

    generated_text
  end

  private

  def setup_data(n)
    CSV.table(@filename, headers: true).each do |line|
      preprocessed_text = preprocess(line[:text])
      text = [NONWORD, NONWORD] + @tagger.parse(preprocessed_text).split + [NONWORD]
      text.each_cons(n) do |word1, word2, word3|
        @markov_data[[word1, word2]] ||= []
        @markov_data[[word1, word2]] << word3
      end
    end
  end

  def preprocess(text)
    text
      .yield_self { |s| remove_url(s) }
      .yield_self { |s| remove_user_at(s) }
      .yield_self { |s| remove_hash(s) }
      .yield_self { |s| remove_RT(s) }
  end

  def remove_url(text)
    text.gsub(/https?:\/\/[\S]+/, '')
  end

  def remove_user_at(text)
    text.gsub(/@[\S]+/, '')
  end

  def remove_hash(text)
    text.gsub(/#[\S]+/, '')
  end

  def remove_RT(text)
    text.gsub(/^RT /, '')
  end
end
