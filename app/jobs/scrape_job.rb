require 'open-uri'
require 'openssl'

class ScrapeJob < ApplicationJob
  queue_as :default

  # default delay between network calls
  DELAY = 4 # seconds

  # RNG
  RNG = Random.new

  # unknown image default url
  UNKNOWN_IMAGE_URL = 'https://upload.wikimedia.org/wikipedia/en/7/73/Image_unavailable.jpg'

  # main method, will run this when called by other class
  def perform(*args)
    puts 'starting scrape'
    skills = Skill.all.shuffle
    skills.each do |skill|
      puts "starting scrape for #{skill.value}"
      scrape_amazon(skill.value)
      #scrape_amazon('javascript')
      scrape_ebay(skill.value)
      #scrape_ebay('javascript')
    end
  end

  # ---- SCRAPE EBAY ----- #

  def scrape_ebay(skill)
    search_url = "http://www.ebay.com.sg/sch/i.html?_ipg=200&_nkw=#{CGI.escape(skill)}+programming+book"

    begin
      # open page with nokogiri
      result_page = Nokogiri::HTML(open(search_url, 'User-Agent' => get_user_agent))

      # get the results, which are elements with the specified css
      results = result_page.css('.sresult') # TODO, follow the amazon example
      puts "number of #{skill} books: #{results.size}"

      if results.blank?
        return puts 'no results, moving on'
      end

      # for each result element, scrape further
      results.each do |result|
        # get the url of the book detail page
        detail_page_url = result.at_css('.vip').attr('href') # TODO, follow the amazon example
        puts "scraping book: #{detail_page_url}"

        # scrape the book detail page since there are more details there
        scrape_detail_ebay(skill, detail_page_url)
        puts "done scraping book: #{detail_page_url}"

        # delay before doing the next book
        sleep(DELAY)
      end

    rescue OpenURI::HTTPError => e
      puts e
      puts 'ending scrape, bye'
      # delay before restarting
      #sleep(DELAY)
      #return scrape_ebay(skill)

    end
  end

  def scrape_detail_ebay(skill, detail_page_url)
    if !detail_page_url.start_with?('http://')
      return puts 'invalid url, moving on'
    end

    begin
      # open the detail page with noko
      book_page = Nokogiri::HTML(open(detail_page_url, 'User-Agent' => get_user_agent))

      # get the isbn-13 number first, if no isbn then we throw away the book
      # get the author too. don't waste the loop and do later
      isNextCellIsbn = false
      isNextCellAuthor = false
      isbn13 = ''
      author = ''

      # .itemAttr table, list the td tags, isbn13 should be inside one of them
      book_page.css('.itemAttr td').each do |node|
        cellContent = node.text.strip
        puts "product details field: #{cellContent}"

        # checks if next cell is author or isbn (due to the way the html is structured)
        if cellContent.include? 'ISBN-13'
          isNextCellIsbn = true
          next
        elsif cellContent.include? 'Author'
          isNextCellAuthor = true
          next
        end

        # if either isNextCellIsbn or isNextCellAuthor is true then record the isbn or author
        if isNextCellIsbn
          isbn13 = cellContent
          isNextCellIsbn = false
        elsif isNextCellAuthor
          author = cellContent
          isNextCellAuthor = false
        end
      end

      # throw book if no isbn
      if isbn13.blank?
        puts 'no isbn, throw away'
        return
      end

      price = ''
      currency = ''

      # loop and get the details of the price
      book_page.css('.vi-price span').each do |node|
        if node.attr('itemprop').eql? 'price'
          price = node.attr('content')
          puts price
        elsif node.attr('itemprop').eql? 'priceCurrency'
          currency = node.attr('content').upcase
          puts currency
        end
      end

      # throw book if no price or price is not usd, cos cannot compare or price cui
      if price.blank? || !currency.eql?('USD')
        puts 'no price, throw away'
        return
      end

      # since there's price, convert it to number
      price = price.to_f

      # get the rest of the relevant data

      # title on book page
      title = book_page.css("#itemTitle").xpath('text()')

      # check if author is successfully captured earlier
      if author.eql? ''
        puts 'really no author'
      end

      # coverurl on book page
      image_url = book_page.css("#icImg").attr('src')

      # all data farmed

      # now to find matching isbn
      existing_book = Book.find_by(isbn13: isbn13)
      if existing_book.blank?
        # no existing book hence create new record
        insert_book(title, isbn13, author, detail_page_url, 'ebay', image_url, price, skill)
      else
        # book exists so compare prices
        update_book(isbn13, price, title, author, detail_page_url, 'ebay', image_url)
      end

    rescue OpenURI::HTTPError => e
      puts e
      puts 'error, try again'
      # delay before restarting
      sleep(DELAY)
      scrape_detail_ebay(skill, detail_page_url)
    end
  end

  # ---------------------- #

  # ---- SCRAPE AMAZON ----- #

  def scrape_amazon(skill)
    search_url = "https://www.amazon.com/s/?field-keywords=#{CGI.escape(skill)}+programming+book"

    begin
      # open page with nokogiri
      result_page = Nokogiri::HTML(open(search_url, 'User-Agent' => get_user_agent))

      # get the results, which are elements with the specified css
      results = result_page.css('.s-result-item')
      puts "number of #{skill} books: #{results.size}"

      if results.blank?
        return puts 'no results, moving on'
      end

      # for each result element, scrape further
      results.each do |result|
        # get the url of the book detail page
        detail_page_url = result.at_css('a.s-access-detail-page').attr('href')
        puts "scraping book: #{detail_page_url}"

        # scrape the book detail page since there are more details there
        scrape_detail_amazon(skill, detail_page_url)
        puts "done scraping book: #{detail_page_url}"

        # delay before doing the next book
        sleep(DELAY)
      end

    rescue OpenURI::HTTPError => e
      puts e
      puts 'ending scrape, bye'
      # delay before restarting
      #sleep(DELAY)
      #return scrape_amazon(skill)

    end
  end

  def scrape_detail_amazon(skill, detail_page_url)
    unless detail_page_url.start_with?('https://')
      return puts 'invalid url, moving on'
    end

    begin
      # open the detail page with noko
      book_page = Nokogiri::HTML(open(detail_page_url, 'User-Agent' => get_user_agent))

      # get the isbn-13 number first, if no isbn then we throw away the book
      isbn13 = ''

      # product details table, list the li tags, isbn13 should be inside one of them
      book_page.css('#productDetailsTable li').each do |node|
        split = node.text.split(' ')
        puts "product details field: #{split}"
        if split[0].include? 'ISBN-13'
          isbn13 = split[1].tr('-', '')
          break
        end
      end

      # throw book if no isbn
      if isbn13.blank?
        puts 'no isbn, throw away'
        return
      end

      # get the price on book page, hardcoded to only get the new book price
      price = ''
      if book_page.css('#newOfferAccordionRow span.header-price').count > 0
        price = book_page.at_css('#newOfferAccordionRow span.header-price').text.strip[1..-1]

      elsif book_page.css('span.a-exisize-medium.a-color-price.offer-price.a-text-normal').count > 0
        price = book_page.css('span.a-size-medium.a-color-price.offer-price.a-text-normal').text.strip[1..-1]

      elsif book_page.css('#addToCart span.header-price').count > 0
        price = book_page.at_css('#addToCart span.header-price').text.strip[1..-1]

      elsif book_page.css('#buyNewSection span.a-size-medium.a-color-price.offer-price.a-text-normal').count > 0
        price = book_page.at_css('#buyNewSection span.a-size-medium.a-color-price.offer-price.a-text-normal').text.strip[1..-1]

      elsif book_page.css('#mediaTab_content_landing span.header-price').count > 0
        price = book_page.at_css('#mediaTab_content_landing span.header-price').text.strip[1..-1]
      end

      # throw book if no price, cos cannot compare
      if price.blank?
        puts 'no price, throw away'
        return
      end

      # since there's price, convert it to number
      price = price.to_f

      # get the rest of the relevant data

      # title on book page
      title = ''
      if book_page.css("#productTitle").count > 0
        title = book_page.at_css("#productTitle").text
      else
        title = book_page.at_css("#ebooksProductTitle").text
      end

      # author info on book page
      author = ''
      if book_page.css('a.contributorNameID').count > 0
        # authorname on book page
        author = book_page.at_css('a.contributorNameID').text
      else
        # authorname on book page
        author = book_page.at_css('span.author>a').text
      end

      # coverurl on book page
      image_url = ''
      if book_page.css('#imgBlkFront').count > 0
        # some problem, always returning base64 encoding, dunno how to avoid that
        image_url = book_page.css('#imgBlkFront').attr('src')
        puts "image url: #{image_url}"
      end

      # all data farmed

      # now to find matching isbn
      existing_book = Book.find_by(isbn13: isbn13)
      if existing_book.blank?
        # no existing book hence create new record
        insert_book(title, isbn13, author, detail_page_url, 'amazon', image_url, price, skill)
      else
        # book exists so compare prices
        update_book(isbn13, price, title, author, detail_page_url, 'amazon', image_url)
      end

    rescue OpenURI::HTTPError => e
      puts e
      puts 'error, try again'
      # delay before restarting
      sleep(DELAY)
      scrape_detail_amazon(skill, detail_page_url)
    end
  end

  # updates a book in the database if it meets the following conditions
  #   is from another store and is cheaper
  #   is from same store
  # should be usable by both amazon and ebay scrape functions
  def update_book(isbn13, price, title, author, url, shop, image_url)
    book = Book.find_by(isbn13: isbn13)

    # compare prices, it should work since price should be a number here
    if (book.price >= price and book.shop != shop) or book.shop == shop
      book.price = price
      book.title = title
      book.author_name = author
      book.url = url
      book.shop = shop
      book.image_url = image_url.blank? ? UNKNOWN_IMAGE_URL : image_url
      book.is_scraped = true

      book.save
    end

  end

  # creates a new book in the database
  # should be usable by both amazon and ebay scrape functions
  def insert_book(title, isbn13, author, url, shop, image_url, price, skill)
    book = Book.new

    book.isbn13 = isbn13
    book.title = title.blank? ? 'Unknown Title' : title
    book.author_name = author.blank? ? 'Unknown Author' : author
    book.url = url
    book.shop = shop
    book.image_url = image_url.blank? ? UNKNOWN_IMAGE_URL : image_url
    book.price = price
    book.skill = skill
    book.is_scraped = true

    book.save
  end

  # set the User-Agent string to bypass scraping block on amazon
  def get_user_agent
    user_agent = "Mozilla/5.0 (X11; U; Linux i686; en-US) AppleWebKit/534.#{RNG.rand(1..99)} (KHTML, like Gecko) Chrome/6.0.472.#{RNG.rand(1..99)} Safari/534.3"
    puts "user_agent: #{user_agent}"
    return user_agent
  end

end
