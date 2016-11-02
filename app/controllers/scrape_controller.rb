class ScrapeController < ApplicationController

  def index
    # asd
  end

  def rescrape
    # send this to a background job
    password = params['password']
    if password == 'password123'
      ScrapeJob.perform_later
      redirect_to root_path
    else
      redirect_to admin_path
    end
  end

end