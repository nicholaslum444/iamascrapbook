class Book < ApplicationRecord
  def self.search(search)
    where("isbn13 LIKE ? OR title LIKE ? OR author_name LIKE ? or skill LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%")
  end
end