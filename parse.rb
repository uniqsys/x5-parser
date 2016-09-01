#!/usr/bin/env ruby

require 'bundler'
Bundler.require

def import_krasnoe
  index_doc = Nokogiri::HTML(
    HTTParty.get('http://krasnoeibeloe.ru/catalog/', cookies: { BITRIX_SM_main_shop: 7535 })
  )

  categories = index_doc.search('.catalog_top_sections__item__pic a').map { |n|
    n['href'].gsub('/catalog', '').gsub('/', '')
  }

  categories.flat_map { |category|
    doc = Nokogiri::HTML(
      HTTParty.get("http://krasnoeibeloe.ru/catalog/#{category}/?page_count=1000", cookies: { BITRIX_SM_main_shop: 7535 })
    )

    doc.search('.catalog_product_item').map { |pn|
      Hashie::Mash.new(
        name: pn.search('.product_item_name').first.text.strip.gsub(/\s+/, ' '),
        price: pn.search('.i_price').text.to_f
      )
    }
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

