module TwitterBackup
  module UI
    class << self
      def ask_credentials
        say "You need to give us necessary credentials"
        say "Get them at https://dev.twitter.com/apps"

        existing_credentials = TBConfig.options[:credentials]
        new_credentials = {}

        new_credentials[:consumer_key]       = ask("Consumer key?  ").to_s          if existing_credentials[:consumer_key].blank?
        new_credentials[:consumer_secret]    = ask("Consumer secret?  ").to_s       if existing_credentials[:consumer_secret].blank?
        new_credentials[:oauth_token]        = ask("Access token?  ").to_s          if existing_credentials[:oauth_token].blank?
        new_credentials[:oauth_token_secret] = ask("Access token secret?  ").to_s   if existing_credentials[:oauth_token_secret].blank?

        TBConfig.save_credentials new_credentials
        raise MissingCredentials if TBConfig.credentials_missing?
      end

      def define_path_to_backup
        default_path = File.join(CONFIG_DIR, "tweets.yml")
        say "We are going to save your tweets to #{TBConfig.options[:db][:database]}"
        say "And also as plain text to #{default_path}"
        if agree ("Dou you want to define another directory for text copy?  ")
          backup_dir = ask("Enter a path to your direcory:  ") do |q|
            q.validate = lambda { |file| File.exist?(File.dirname(File.expand_path(file))) }
            q.responses[:not_valid] = "You can't save files there"
            q.confirm  = true
          end
          backup_file = File.expand_path(File.join(backup_dir, "tweets.yml"))
        else
          backup_file = default_path
        end
        
        TBConfig.save_backup_file backup_file
        
      end

      def greet_user
        say %[.... <%= color("Tweets for: #{TBConfig.user.name}", GREEN) %>!]
        say %[.... Your tweets at twitter.com: #{TBConfig.user.statuses_count}]
      end

      def exit_screen
        if ActiveRecord::Base.connected?
          say %[.... Your tweets in this backup: #{Tweet.count}]
          if Tweet.earliest.present?
            say %[.... Your earliest tweet:]
            say %[.... <%= color("#{Tweet.earliest.try(:status)}", YELLOW) %>]
          end
          if Tweet.latest.present?
            say %[.... Your latest tweet:]
            say %[.... <%= color("#{Tweet.latest.try(:status)}", GREEN) %>]
          end
        end
      end

      def missing_credentials_exit
        say %[.... <%= color("We can't work without credentials. Sorry.", RED) %>]
        say ".... Go get them at https://dev.twitter.com/apps"
        say ".... And run this script again"
        exit 1
      end

      def wrong_credentials_exit
        say %[.... <%= color("Your credentials are somehow wrong.", RED) %>]
        say ".... Go get the right ones at https://dev.twitter.com/apps"
        say ".... And run this script again"
        exit 1
      end

      def failed_backup_path_exit message
        say %[.... <%= color("We've failed to create #{TBConfig.options[:backup_file]} for you.", RED) %>]
        say %[.... #{message}]
        TBConfig.save_backup_file("")
        say ".... Run this script again and chose another place to store your backup"
        say ".... Or edit it manually at #{TBConfig.config_file}"
        exit 1
      end

      def too_many_requests_exit
        say %[.... <%= color("You've exceeded your request limit", RED) %>]
        say ".... Try again tomorrow =)"
        exit 1
      end

    end
  end
end