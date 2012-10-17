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

        if TBConfig.credentials_missing?
          missing_credentials_exit
        end
      end

      def define_path_to_backup
        default_dir = File.join(CONFIG_DIR, "tweets.yml")
        say "We are going to save your tweets to #{TBConfig.options[:db][:database]}"
        say "And also as plain text to #{default_dir}"
        if agree ("Dou you want to define another directory for text copy?  ")
          backup_dir = ask("Enter a path to your direcory:  ") do |q|
            q.validate = lambda { |file| File.exist?(File.dirname(File.expand_path(file))) }
            q.responses[:not_valid] = "You can't save files there"
            q.confirm  = true
          end
          backup_file = File.expand_path(File.join(backup_dir, "tweets.yml"))
          TwitterBackup.prepare_file backup_file
          if File.exists? backup_file
            say "Your tweets will be saved at #{backup_file}"
            TBConfig.save_backup_file backup_file
          else
            failed_backup_path_exit(backup_file)
          end
        end
      end

      def greet_user
        say %[===================================]
        say %[Tweets for: <%= color("#{TBConfig.user.name}", GREEN) %>!]
        say %[Your tweets at twitter.com: #{TBConfig.user.statuses_count}]
      end

      def exit_screen
        say %[Your tweets in this backup: #{Tweet.count}]
        say %[Your earliest tweet:]
        say %[  <%= color("#{Tweet.earliest.status}", YELLOW) %>]
        say %[Your latest tweet:]
        say %[  <%= color("#{Tweet.latest.status}", GREEN) %>]
        say %[===================================]
      end

      def missing_credentials_exit
        say %[<%= color("We can't work without credentials. Sorry.", RED) %>]
        say "Go get them at https://dev.twitter.com/apps"
        say "And run this script again"
        exit 0
      end

      def wrong_credentials_exit
        say %[<%= color("Your credentials are somehow wrong.", RED) %>]
        say "Go get the right ones at https://dev.twitter.com/apps"
        say "And run this script again"
        exit 0
      end

      def failed_backup_path_exit file
        say %[<%= color("We've failed to create #{file} for you.", RED) %>]
        say "Run this script again and chose another place to store your backup"
        say "Or edit it manually at #{CONFIG_FILE}"
        exit 0
      end

      def too_many_requests_exit
        say %[<%= color("You've exceeded your request limit", RED) %>]
        say "Try again tomorrow =)"
        exit 0
      end



    end
  end
end