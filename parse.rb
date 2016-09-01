#!/usr/bin/env ruby

require 'bundler'
Bundler.require

def import_krasnoe
  doc = Nokogiri::HTML(
    HTTParty.get('http://krasnoeibeloe.ru/catalog/vino/?form_id=catalog_filter_form&arrFilter_121_MIN=84&arrFilter_121_MAX=18900&catalog_shop_enabled=Array&arrFilter_100_MIN=0.19&arrFilter_100_MAX=3&filter_search=&arrFilter_103_MIN=0&arrFilter_103_MAX=20&set_filter=Y&sort_by=name&page_count=1000&submit=%D0%9E%D0%9A')
  )

  doc.search('.catalog_product_item').map { |pn|
    Hashie::Mash.new(
      name: pn.search('.product_item_name').first.text.strip.gsub(/\s+/, ' '),
      price: pn.search('.i_price').text.to_f
    )
  }
end

def import_5ka
  response = Hashie::Mash.new(
    HTTParty.get('https://5ka.ru/api/special_offers/?records_per_page=1000&page=1', verify: false))

  response.results.map { |e|
    Hashie::Mash.new(name: e.name, price: e.params.special_price.to_f)
  }
end

CSV.open('products.csv', 'wb') do |csv|
  import_5ka.each do |good|
    csv << ['Москва', 'Пятёрочка', good.name, good.price]
  end

  import_krasnoe.each do |good|
    csv << ['Москва, пер. 2-й Кожевнический, 1', 'Красное и Белое', good.name, good.price]
  end
end

puts 'Well done!'

