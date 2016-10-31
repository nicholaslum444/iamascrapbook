class BooksController < ApplicationController
  def index
    @books = Book.all
	if params[:search]
    @books = Book.search(params[:search]).order("created_at DESC")
  else
    @books = Book.all.order("created_at DESC")
  end
  end

  def create
  end

  def new
  end

  def edit
  end

  def show
  end

  def update
  end

  def destroy
  end
end
