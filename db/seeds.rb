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
                            title: 'javascript abc',
                            author_name: 'nick lum',
                            author_bio: 'he is cool',
                            desc: 'a book on js',
                            price: 3.16,
                            rating: 4.5,
                            image_url: 'http://www.pngall.com/wp-content/uploads/2016/03/John-Cena-Logo-PNG.png',
                            skill: 'javascript',
                            is_scraped: false,
                            url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
                        },
                        {
                            title: 'java abc',
                            author_name: 'nick lumply',
                            author_bio: 'he is hot not cool',
                            desc: 'a book on jv',
                            price: 3.17,
                            rating: 4.1,
                            image_url: 'https://i.ytimg.com/vi/RY7vcYvb69k/maxresdefault.jpg',
                            skill: 'java',
                            is_scraped: false,
                            url: 'https://www.youtube.com/watch?v=d9TpRfDdyU0'
                        }
                    ]);