require 'open-uri'
require 'openssl'

class ScrapeJob < ApplicationJob

  # default delay between network calls
  DELAY = 2

  # set the User-Agent string to bypass scraping block on amazon
  USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2'

  queue_as :default

  def perform(*args)
    Skill.all.each do |skill|
      scrape_amazon(skill.value)
      scrape_ebay(skill.value)
    end
  end

  # ---- SCRAPE EBAY ----- #

  def scrape_ebay(skill)
    search_url = 'http://www.ebay.com.sg/sch/i.html?_ipg=200&_nkw=' + CGI.escape(skill) + '+programming+book'

    #TODO code Nokogiri
  end

  # ---------------------- #

  # ---- SCRAPE AMAZON ----- #

  def scrape_amazon(skill)
    search_url = 'https://www.amazon.com/s/?field-keywords=' + CGI.escape(skill) + '+programming+book'

    begin
      # open page with nokogiri
      result_page = Nokogiri::HTML(open(search_url, 'User-Agent' => USER_AGENT))

      # get the results, which are elements with the specified css
      results = result_page.css('.s-result-item')

      # delay before crawling each book
      sleep(DELAY)

      # for each result element, scrape further
      results.each do |result|
        # get the url of the book detail page
        detail_page_url = result.at_css('a.s-access-detail-page').attr('href')

        # scrape the book detail page since there are more details there
        scrape_detail_amazon(detail_page_url)

        # delay before doing the next book
        sleep(DELAY)
      end

    rescue OpenURI::HTTPError
      # delay before restarting
      sleep(DELAY)
      return scrape_amazon(skill)

    end
  end

  def scrape_detail_amazon(detail_page_url)
    begin
      # open the detail page with noko
      book_page = Nokogiri::HTML(open(detail_page_url, 'User-Agent' => USER_AGENT))

      # get the isbn-13 number first, if no isbn then we throw away the book
      isbn = ''

      # product details table, list the li tags, isbn13 should be inside one of them
      book_page.css('#productDetailsTable li').each do |node|
        split = node.text.split(' ')
        if (split[0].include? 'ISBN-13')
          isbn = split[1]
          break
        end
      end

      # throw book if no isbn
      if isbn.blank?
        return
      end

      # now to find matching isbn

      # title on book page
      if (book_page.css("#productTitle").count > 0)
        resultObj.setTitle(book_page.at_css("#productTitle").text);
      else
        resultObj.setTitle(book_page.at_css("#ebooksProductTitle").text);
      end

      # author info on book page
      if (book_page.css("a.contributorNameID").count > 0)
        # authorname on book page
        resultObj.setAuthorName(book_page.at_css("a.contributorNameID").text)
        # authorurl on book page
        resultObj.setAuthorUrl(book_page.at_css("a.contributorNameID").attr("href"))
        scrapeAuthor(resultObj, resultObj.getAuthorUrl)
      else
        # authorname on book page
        resultObj.setAuthorName(book_page.at_css("span.author>a").text)
      end

      # rating on book page
      if (book_page.css("#acrPopover").count > 0)
        resultObj.setRating(book_page.at_css("#acrPopover").attr("title"))
      end

      # coverurl on book page
      if (book_page.css("#imgBlkFront").count > 0)
        resultObj.setCoverUrl(book_page.at_css("#imgBlkFront").attr("src"))
      end

      # first price on book page
      if (book_page.css("#newOfferAccordionRow span.header-price").count > 0)
        resultObj.setPrice(book_page.at_css("#newOfferAccordionRow span.header-price").text.strip[1..-1])
      end

    rescue OpenURI::HTTPError
      # delay before restarting
      sleep(DELAY)
      scrape_detail_amazon(detail_page_url)
    end
  end

  def scrapeAuthor(resultObj, authorUrl)
    # authorbio on author page
    begin
      if (authorUrl != -1)
        authorPage = Nokogiri::HTML(open(@@baseUrl + authorUrl))
        if (authorPage.css("#ap-bio span").count > 0)
          bio = authorPage.at_css("#ap-bio span").text.strip
          if (bio.length > 0)
            resultObj.setAuthorBio(bio)
          end
        end
      end
    rescue OpenURI::HTTPError
      scrape_detail_amazon(resultObj, authorUrl)
    end
  end

  def updateBookData(book, resultObj, skill)
    book.url = resultObj.getUrl
    book.title = resultObj.getTitle
    book.author_name = resultObj.getAuthorName != -1 ? resultObj.getAuthorName : "Unknown Author"
    book.author_bio = resultObj.getAuthorBio != -1 ? resultObj.getAuthorBio : "Author Bio Unavailable"
    book.desc = resultObj.getDesc != -1 ? resultObj.getDesc : "Description Unavailable"
    book.price = resultObj.getPrice != -1 ? resultObj.getPrice : 0.00
    book.rating = resultObj.getRating != -1 ? resultObj.getRating : "Rating unavailable"
    book.image_url = resultObj.getCoverUrl != -1 ? resultObj.getCoverUrl : "https://upload.wikimedia.org/wikipedia/en/7/73/Image_unavailable.jpg"
    book.skill = skill
    book.is_scraped = true;
    book.save
  end

end
