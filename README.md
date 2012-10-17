# TwitterBackup

This gem will download your tweets from Twitter and save them in an sqlite3 database and plaintext (yaml) archive file.

## Installation

    $ gem install twitter_backup

## Usage

First of all, you need to create an app at https://dev.twitter.com/apps
Your app will be assigned a 'consumer key'/'consumer secret' pair and you as a user will be assigned an 'access token/acces token secret' OAuth pair for that application.
Without these credentials you won't be able to use TwitterBackup.

Now, all you have to do is to run a script

    $ twitter_backup

## TODO

- Replace seeding and updating with just one method. Remove everything about seeding.
- Prepend RT @retweeted_user to retweets