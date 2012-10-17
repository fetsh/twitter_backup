# TwitterBackup

This gem will download your tweets from Twitter and save them to sqlite3 database and plaintext (yaml) archive file.

## Installation

    $ gem install twitter_backup

## Usage

First of all, you need to create an app at https://dev.twitter.com/apps
Your app will be assigned a 'consumer key'/'consumer secret' pair and you as a user will be assigned an 'access token'/'acces token secret' OAuth pair for that application.
Without these credentials you won't be able to use TwitterBackup.

Now, all you have to do is to run

    $ twitter_backup

If you want to know, what's happening during your backup process, use verbose mode with `-v`.

    $ twitter_backup -h
        -v, --verbose      Enable verbose mode
        -f, --force        Try to download tweets, even if it seems useless
        -s, --seed         Try to download tweets older than the oldest one you have
        -c, --config       Config file. Default: ~/.config/twitter_backup/config.yml
        -h, --help         Display this help message.

## TODO

- Automate adding this script to cron?