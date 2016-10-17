require 'open-uri'

class ScrapeController < ApplicationController
  @@baseUrl = "http://www.amazon.com"

  # Result class to help consolidate results
  class Result

    def initialize
      @url = -1
      @title = -1
      @authorName = -1
      @authorUrl = -1
      @authorBio = -1
      @rating = -1
      @coverUrl = -1
      @price = -1
      @desc = -1
    end

    def setUrl(url)
      @url = url
    end
    def getUrl
      return @url
    end

    def setTitle(title)
      @title = title
    end
    def getTitle
      return @title
    end

    def setAuthorName(authorName)
      @authorName = authorName
    end
    def getAuthorName
      return @authorName
    end

    def setAuthorUrl(authorUrl)
      @authorUrl = authorUrl
    end
    def getAuthorUrl
      return @authorUrl
    end

    def setAuthorBio(authorBio)
      @authorBio = authorBio
    end
    def getAuthorBio
      return @authorBio
    end

    def setRating(rating)
      @rating = rating
    end
    def getRating
      return @rating
    end

    def setCoverUrl(coverUrl)
      @coverUrl = coverUrl
    end
    def getCoverUrl
      return @coverUrl
    end

    def setPrice(price)
      @price = price
    end
    def getPrice
      return @price
    end

    def setDesc(desc)
      @desc = desc
    end
    def getDesc
      return @desc
    end

  end
  # End Results class

  def index
    Skill.all.each do |skill|
      scrape(skill.value)
    end
    #scrape("c")
    #scrape("c++")
    #scrape("java")
    #scrape("javascript")
    #scrape("ruby")
    @books = Book.all
    render json: [@books, @books.count, Skill.all.count]
  end

  def scrape(skill)
    searchFormat = "/s/?field-keywords=" + CGI.escape(skill) + "+book"
    goUrl = @@baseUrl + searchFormat
    scrapeResults(goUrl).each do |resultObj|
      title = resultObj.getTitle
      if (title == -1)
        next
      end
      @bookset = Book.where(title: title)
      if @bookset.count <= 0
        @book = Book.new(params[:book])
        updateBookData(@book, resultObj, skill)
      else
        updateBookData(@bookset.first, resultObj, skill)
      end
    end
    @books = Book.all
  end

  private

  def scrapeResults(resultsUrl)
    begin
      resultPage = Nokogiri::HTML(open(resultsUrl))
      results = resultPage.css(".s-result-item")
      resultObjArray = []
      results.each do |result|
        resultObj = Result.new
        resultObj.setUrl(result.at_css("a.s-access-detail-page").attr("href"))
        scrapeBook(resultObj, resultObj.getUrl)
        resultObjArray.push(resultObj)
      end
      return resultObjArray;
    rescue OpenURI::HTTPError
      return scrapeResults(resultsUrl)
    end
  end

  def scrapeBook(resultObj, bookUrl);
  begin
    bookPage = Nokogiri::HTML(open(bookUrl))
    # title on book page
    if (bookPage.css("#productTitle").count > 0)
      resultObj.setTitle(bookPage.at_css("#productTitle").text);
    else
      resultObj.setTitle(bookPage.at_css("#ebooksProductTitle").text);
    end

    # author info on book page
    if (bookPage.css("a.contributorNameID").count > 0)
      # authorname on book page
      resultObj.setAuthorName(bookPage.at_css("a.contributorNameID").text)
      # authorurl on book page
      resultObj.setAuthorUrl(bookPage.at_css("a.contributorNameID").attr("href"))
      scrapeAuthor(resultObj, resultObj.getAuthorUrl)
    else
      # authorname on book page
      resultObj.setAuthorName(bookPage.at_css("span.author>a").text)
    end

    # rating on book page
    if (bookPage.css("#acrPopover").count > 0)
      resultObj.setRating(bookPage.at_css("#acrPopover").attr("title"))
    end

    # coverurl on book page
    if (bookPage.css("#imgBlkFront").count > 0)
      resultObj.setCoverUrl(bookPage.at_css("#imgBlkFront").attr("src"))
    end

    # first price on book page
    if (bookPage.css("#newOfferAccordionRow span.header-price").count > 0)
      resultObj.setPrice(bookPage.at_css("#newOfferAccordionRow span.header-price").text.strip[1..-1])
    end

      # description on book page
      #if (bookPage.css("#bookDesc_iframe").count > 0)
      #resultObj.setDesc(bookPage.css("#bookDesc_iframe_wrapper"))
      #end
      ##### NOTE ######
      # Description cannot be farmed because it is loaded via javascript.
      # No time to learn new tech to get the description from js
      # :((((

  rescue OpenURI::HTTPError
    scrapeBook(resultObj, bookUrl)
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
      scrapeAuthor(resultObj, authorUrl)
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