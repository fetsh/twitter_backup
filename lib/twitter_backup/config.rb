
CONFIG_DIR = File.expand_path(File.join("~/", ".config", "twitter_backup"))
CONFIG_FILE = File.join(CONFIG_DIR, "config.yml")

CONFIG_DEFAULTS = {
  :CREDENTIALS => {
    :consumer_key => "",
    :consumer_secret => "",
    :oauth_token => "",
    :oauth_token_secret => "",
    },
  :db => {
    :adapter => "sqlite3",
    :database => File.join(CONFIG_DIR, "tweets.sqlite3"),
    :pool => 5,
    :timeout => 5000
    },
  :backup_file => File.join(CONFIG_DIR, "tweets"),
  :initial_seeded => false
}

module TwitterBackup
  class Config
    class << self
      def load
        TwitterBackup.prepare_file CONFIG_FILE
        yaml = YAML::load_file( CONFIG_FILE )
        @@options = if yaml.is_a? Hash
          CONFIG_DEFAULTS.merge(yaml)
        else
          CONFIG_DEFAULTS
        end
      end

      def save options
        @@options = options
        TwitterBackup.prepare_file CONFIG_FILE
        File.open( CONFIG_FILE, "w" ){|f| YAML::dump( options, f )}
      end

      def options
        @@options ||= load
      end

      def credentials_missing?
        options[:CREDENTIALS].values.map(&:strip).include? ""
      end

      def save_credentials new_credentials
        options[:CREDENTIALS] = options[:CREDENTIALS].merge(new_credentials)
        save options
      end

      def empty_credentials
        new_credentials = { :consumer_key => "",
                            :consumer_secret => "",
                            :oauth_token => "",
                            :oauth_token_secret => ""}
        save_credentials new_credentials
      end

      def configure_database
        ActiveRecord::Base.establish_connection(options[:db])
        unless ActiveRecord::Base.connection.tables.include?("tweets")
          ActiveRecord::Migration.create_table :tweets do |t|
            t.text :status
            t.integer :status_id
            t.timestamp :created_at
          end
        end
      end

      def configure_twitter_gem
        Twitter.configure do |config|
          config.consumer_key = options[:CREDENTIALS][:consumer_key]
          config.consumer_secret = options[:CREDENTIALS][:consumer_secret]
          config.oauth_token = options[:CREDENTIALS][:oauth_token]
          config.oauth_token_secret = options[:CREDENTIALS][:oauth_token_secret]
        end
      end

      def verify_credentials
        begin
          user = Twitter.verify_credentials(:skip_status => true, :include_entities => false)
        rescue Twitter::Error::Unauthorized => error
          empty_credentials
          TwitterBackup::UI.wrong_credentials_exit
        end
      end

      def seeded?
        true == options[:initial_seeded]
      end

      def mark_as_seeded
        options[:initial_seeded] = true
        save options
      end

    end
  end
end