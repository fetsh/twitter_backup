module TwitterBackup
  class Tweet < ActiveRecord::Base
    class << self

      def update_tweets
        say "Updating tweets ......"
      end

      def seed_tweets
        say "Seeding tweets ......"
      end

    end
  end
end
