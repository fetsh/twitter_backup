module TwitterBackup
  class Tweet < ActiveRecord::Base

    serialize :raw

    scope :slim, select([:id, :created_at, :status, :status_id])
    
    class << self

      def update_tweets(args={})
        args = {
          :from    => nil,
          :to    => latest.try(:status_id)
        }.merge(args)
        if args[:from] == :earliest
          args[:from] = earliest.try(:status_id)
          args[:to] = nil if args[:to] == latest.try(:status_id)
        end
        if !synced? || TBConfig.passed_opts.force?
          say ".... Updating tweets from #{args[:from] || 'the youngest one'} to #{args[:to] || 'the oldest one'}" if TBConfig.passed_opts.verbose?
          download(:from => args[:from], :to => args[:to]).each do |tweet|
            if absent_tweet = find_by_status_id(tweet.id)
              next
            else
              say %[<%= color(".", YELLOW) %> ] if TBConfig.passed_opts.verbose?
              tweet_text = if tweet.retweet?
                "RT @#{tweet.retweeted_status.user.screen_name}: #{tweet.retweeted_status.text}"
              else
                tweet.text
              end
              create(
                :status_id => tweet.id,
                :status => tweet_text,
                :created_at => tweet.created_at,
                :raw => tweet
              )
            end
          end
          say "!"
          say ".... Updating succeeded" if TBConfig.passed_opts.verbose?
        else
          say ".... Seems like there is nothing we can update" if TBConfig.passed_opts.verbose?
        end
      end

      def latest
        self.slim.order("created_at DESC").first
      end
      def earliest
        self.slim.order("created_at DESC").last
      end

      def download(args={})
        args = {
          :from    => nil,
          :to    => nil
        }.merge(args)
        args[:from], args[:to] = [args[:from], args[:to]].sort.reverse unless [args[:from], args[:to]].include? nil

        needed_tweets = []

        if args[:from].blank?
          say ".... user_timeline API request" if TBConfig.passed_opts.verbose?
          received_tweets = Twitter.user_timeline(:count => 200)
        else
          say ".... user_timeline API request" if TBConfig.passed_opts.verbose?
          received_tweets = Twitter.user_timeline(:count => 200, :max_id => args[:from])
        end

        if args[:to].blank?
          id_of_the_earliest_received_tweet = nil
          until id_of_the_earliest_received_tweet == received_tweets.last.id
            id_of_the_earliest_received_tweet = received_tweets.last.id
            say ".... user_timeline API request" if TBConfig.passed_opts.verbose?
            received_tweets.concat(
                Twitter.user_timeline(:count => 200, :max_id => received_tweets.last.id)
            )
          end
          received_tweets
        else args[:to]
          id_of_the_earliest_needed_tweet = args[:to]
          until received_tweets.map(&:id).include? id_of_the_earliest_needed_tweet
            say ".... user_timeline API request" if TBConfig.passed_opts.verbose?
            received_tweets.concat(
                Twitter.user_timeline(:count => 200, :max_id => received_tweets.last.id)
            )
          end
          index_of_earliest_needed_tweet = received_tweets.rindex{|tweet| tweet.id == id_of_the_earliest_needed_tweet}
          received_tweets[0..index_of_earliest_needed_tweet]
        end

      end

      def synced?
        self.count == TBConfig.user.statuses_count
      end

      def dump_to_backup_file
        if TBConfig.passed_opts.verbose?
          say ".... Saving tweets to: #{TBConfig.options[:backup_file]}"
        end
        tweets = slim.order("created_at DESC").map{ |tweet| {
                                          :id => tweet.status_id,
                                          :text => tweet.status,
                                          :created_at => tweet.created_at,
                                          :link => tweet.public_link } }
        File.open( TBConfig.options[:backup_file], "w" ) { |f| YAML::dump( tweets, f ) }
      end
    end

    def public_link
      "https://twitter.com/#{TBConfig.user.screen_name}/status/#{self.status_id}"
    end

  end
end
