# 0. General Information

* Ruby version: 2.2.2
* Rails version: 5.0.0.1
* Recommended platform: Linux or MacOS

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

1. `todo`

# 4. FAQ

1. `todo`
