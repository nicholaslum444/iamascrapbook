class Book < ApplicationRecord
def self.search(search)
  where("id LIKE ? OR title LIKE ? OR author_name LIKE ? or skill LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%") 
end
end