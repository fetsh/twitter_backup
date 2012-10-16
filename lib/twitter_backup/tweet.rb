module TwitterBackup
  class Tweet < ActiveRecord::Base
    class << self

      def update_tweets
        say ".... Updating tweets" if TBConfig.passed_opts.verbose?
        unless synced?
          download(:to => latest.try(:status_id)).each do |tweet|
            find_or_create_by_status_id(
                    :status_id => tweet.id,
                    :status => tweet.text,
                    :created_at => tweet.created_at
            )
          end
        end
        say ".... Succeeded. Up to date" if synced? && TBConfig.passed_opts.verbose?
      end

      def seed_tweets
        say ".... Seeding" if TBConfig.passed_opts.verbose?
        if synced?
          TBConfig.mark_as_seeded
        else
          download(:from => earliest.try(:status_id)).each do |tweet|
            find_or_create_by_status_id(
                    :status_id => tweet.id,
                    :status => tweet.text,
                    :created_at => tweet.created_at
            )
          end
          TBConfig.mark_as_seeded if synced?
        end
        say ".... Succeeded. Seeded" if TBConfig.seeded? && TBConfig.passed_opts.verbose?
      end

      def latest
        self.order("created_at DESC").first
      end
      def earliest
        self.order("created_at DESC").last
      end

      def download(args={})
        args = {
          :from    => nil,
          :to    => nil
        }.merge(args)

        needed_tweets = []

        if args[:from].blank?
          received_tweets = Twitter.user_timeline(:count => 200)
        else
          received_tweets = Twitter.user_timeline(:count => 200, :max_id => args[:from])
        end

        if args[:to].blank?
          id_of_the_earliest_received_tweet = nil
          until id_of_the_earliest_received_tweet == received_tweets.last.id
            id_of_the_earliest_received_tweet = received_tweets.last.id
            received_tweets.concat(
                Twitter.user_timeline(:count => 200, :max_id => received_tweets.last.id)
            )
          end
          received_tweets
        else args[:to]
          id_of_the_earliest_needed_tweet = args[:to]
          until received_tweets.map(&:id).include? id_of_the_earliest_needed_tweet
            received_tweets.concat(
                Twitter.user_timeline(:count => 200, :max_id => received_tweets.last.id)
            )
          end
          index_of_earliest_needed_tweet = received_tweets.rindex{|tweet| tweet.id == id_of_the_earliest_needed_tweet}
          received_tweets[0..index_of_earliest_needed_tweet]
        end

      end

      def synced?
        available_tweets = TBConfig.user.statuses_count
        available_tweets = 3200 if TBConfig.user.statuses_count > 3200
        available_tweets == self.count
      end

      def dump_to_backup_file
        if TBConfig.passed_opts.verbose?
          say ".... Saving tweets to: #{TBConfig.options[:backup_file]}"
        end
        tweets = order("created_at DESC").map{ |tweet| {
                                          :id => tweet.status_id,
                                          :text => tweet.status,
                                          :created_at => tweet.created_at } }
        File.open( TBConfig.options[:backup_file], "w" ) { |f| YAML::dump( tweets, f ) }
      end
    end
  end
end
