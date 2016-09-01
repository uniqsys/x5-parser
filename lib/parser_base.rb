require 'nokogiri'
require 'open-uri'

class ParserBase
  attr_accessor :catalog_url, :result

  def initialize(user_agent = nil)
    @queue = []
    @ua = user_agent
  end

  def ua
    @ua || 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36'
  end

  def queue(url, type = nil, category = nil)
    puts "queue(#{url}, #{type}, #{category})"
    @queue << {
      url: pretty_url(url),
      type: type,
      category: category
    }
  end

  def run
    raise 'Catalog url not set' if catalog_url.nil? || catalog_url.empty?
    queue(catalog_url, :start)

    while @queue.any?
      item = @queue.shift
      page = download(item[:url])
      next unless page
      doc = Nokogiri::HTML(page)
      send("parse_#{item[:type]}", item, doc)
    end
  end

  def download(url)
    open(url, 'User-Agent' => ua).read
  rescue openURI::HTTPError => error
    puts "Error #{error.status} for #{url}"
  end

  def pretty_url(url)
    (URI.parse(catalog_url) + url).to_s
  end
end
