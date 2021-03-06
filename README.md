# 0. General Information

## 0.1. Academic
* School: National University of Singapore
* Course: CS3103
* Group: 01
* Members: Nicholas Lum, Kenneth Ho, Low Wei Kit, Ng Zi Kai

## 0.2. Technical
* Ruby version: 2.2.2
* Rails version: 5.0.0.1
* Recommended platform: Linux or MacOS
* Recommended production web server: apache2

# 1. Setup

## 1.1. MySQL

1. Install MySQL
2. Log in to MySQL using the root account (for convenience)
3. Remember the username and password of the root account; it will be needed later
4. Create the database `iamascrapbook_dev` by running the command `CREATE DATABASE iamascrapbook;`
5. Quit MySQL

## 1.2. database.yml

1. Create `database.yml` in `config/` folder and copy the contents from `database.yml.example` to it
2. In the relevant fields under `development:`, fill in the username and password of your MySQL root account
3. Save the file
4. Ensure the file does not appear in any git commits

## 1.3. secrets.yml

1. Create `secrets.yml` in `config/` folder and copy the contents from `secrets.yml.example` to it
2. Save the file
3. Ensure the file does not appear in any git commits

# 2. Local Deploy

1. Run `bundle install` after carrying out the steps in [Setup](#1-setup) above
2. Run `bundle exec rake db:reset` to prepare the database
3. Run `rails s` to launch the app
4. Visit `http://localhost:3000` on your browser to use the app

# 3. Production Deploy

This section is only relevant if you intend to deploy it in a production environment.

1. Git clone to your preferred webroot and perform the steps in [Setup](#1-setup) above
2. Run `bundle install` in the app folder
3. Run `bundle exec rake db:reset RAILS_ENV=production` to prepare the production database
4. Run `bundle exec rake assets:precompile RAILS_ENV=production` to precompile the app assets
5. Point apache2 to the app folder; Ensure that the line `RailsEnv production` is in the virtual host config file
6. Enable the site with `sudo a2ensite ...` and restart apache2
7. Visit the designated URL with your browser to use the app

# 4. App Usage

This assumes you have already set up the app and it is running on localhost:3000.

1. Visit `localhost:3000/scrape/rescrape` to start the scraping; currently it can only scrape programming books from Amazon.
2. Scraping will take at least half an hour, so leave the site alone and go do some other things in the meantime
3. You can stop the scraping any time by killing the rails server
4. Visit `localhost:300/books` to view the scraped books
