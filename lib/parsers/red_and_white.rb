class RedAndWhiteParser < ParserBase
  def parse_start(item, doc)
    doc.css('.catalog_top_sections__item').each do |elem|
      category = elem.at_css('.catalog_top_sections__item__name').text.strip
      queue(elem.at_css('a')[:href], :category, category)
    end
  end

  def parse_category(item, doc)
    if pagination = doc.css('.bl_pagination > ul > li')
      count = pagination.map { |p| p.text.to_i }.max
      puts "Pagination: #{pagination.map { |p| p.text.to_i }}"
      (2..count).each { |page| queue "#{item[:url]}?PAGEN_1=#{page}", :category, item[:category] }
    end

    doc.css('.catalog_product_item_cont').each do |elem|
      title = elem.at_css('.product_item_name').text.strip
      price = elem.at_css('.i_price').text.delete('₽').strip
      result << [title, price]
    end
  end
end
