require 'open-uri'
require 'openssl'

class ScrapeController < ApplicationController

  def index
    # asd
  end

  def test
    #full_url = "https://www.amazon.com/s/?field-keywords=ruby";
    full_url = "http://nuscomputing.com";
    url = URI.parse(full_url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true if url.port == 443
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if url.port == 443
    path = url.path + '?' + url.query
    res, data = http.get(path)

    case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        # parse link
        resultPage = Nokogiri::HTML(data)
        @results = resultPage.css(".container")
      else
        return "failed" + res.to_s
    end

    open("http://www.amazon.com/s/field-keywords=ruby")
    resultPage = Nokogiri::HTML(open("https://www.amazon.com/s/field-keywords=ruby"))
    @results = resultPage.css(".s-result-item")
  end

  def rescrape
    # send this to a background job
    ScrapeJob.perform_later
  end

  private

end