class ScrapeController < ApplicationController

  def index
    # asd
  end

  def rescrape
    # send this to a background job
    password = params['password']
    puts "entered password: #{password}"
    if password == Rails.application.secrets.admin_password
      ScrapeJob.perform_later
      redirect_to root_path
    else
      redirect_to admin_path
    end
  end

end