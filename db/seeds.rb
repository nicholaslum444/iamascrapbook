# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
skills = Skill.create([
                          {
                              area: 'programming',
                              value: 'c'
                          },
                          {
                              area: 'programming',
                              value: 'c++'
                          },
                          {
                              area: 'programming',
                              value: 'java'
                          },
                          {
                              area: 'programming',
                              value: 'javascript'
                          },
                          {
                              area: 'programming',
                              value: 'ruby'
                          }
                      ]);
books = Book.create([
                        {
                            title: 'The Ruby Programming Language: Everything You Need to Know',
                            isbn13: '978-0596516178',
                            author_name: 'David Flanagan and Yukihiro Matsumoto',
                            shop: 'amazon',
                            url: 'https://www.amazon.com/Ruby-Programming-Language-Everything-Need/dp/0596516177/ref=sr_1_1?ie=UTF8&qid=1478117977&sr=8-1&keywords=ruby+programming+book',
                            price: 3.16,
                            image_url: 'https://images-na.ssl-images-amazon.com/images/I/51i0hr6kccL._SX383_BO1,204,203,200_.jpg',
                            skill: 'ruby',
                            is_scraped: false
                        },
                        {
                            title: 'Java: A Beginner\'s Guide, Sixth Edition',
                            isbn13: '978-0071809252',
                            author_name: 'Herbert Schildt',
                            shop: 'amazon',
                            url: 'https://www.amazon.com/Java-Beginners-Guide-Herbert-Schildt/dp/0071809252/ref=sr_1_1?ie=UTF8&qid=1478121604&sr=8-1&keywords=java+programming+book',
                            price: 4.20,
                            image_url: 'https://images-na.ssl-images-amazon.com/images/I/51hqf-LtShL._SX402_BO1,204,203,200_.jpg',
                            skill: 'java',
                            is_scraped: false
                        }
                    ]);