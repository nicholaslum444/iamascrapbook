module ScrapeHelper

  # Result class to help consolidate results
  class Result

    def initialize
      @title = -1
      @isbn = -1
      @shop = -1
      @url = -1
      @price = -1
      @authorName = -1
      @pictureUrl = -1
      @desc = -1
    end

    def setTitle(title)
      @title = title
    end
    def getTitle
      return @title
    end

    def setIsbn(isbn)
      @isbn = isbn
    end
    def getIsbn
      return @isbn
    end

    def setShop(shop)
      @shop = shop
    end
    def getShop
      return @shop
    end

    def setUrl(url)
      @url = url
    end
    def getUrl
      return @url
    end

    def setPrice(price)
      @price = price
    end
    def getPrice
      return @price
    end

    def setAuthorName(authorName)
      @authorName = authorName
    end
    def getAuthorName
      return @authorName
    end

    def setPictureUrl(pictureUrl)
      @pictureUrl = pictureUrl
    end
    def getPictureUrl
      return @pictureUrl
    end

    def setDesc(desc)
      @desc = desc
    end
    def getDesc
      return @desc
    end

  end
  # End Results class

end
