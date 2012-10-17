
CONFIG_DIR = File.expand_path(File.join("~/", ".config", "twitter_backup"))
CONFIG_FILE = File.join(CONFIG_DIR, "config.yml")

CONFIG_DEFAULTS = {
  :credentials => {
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
  :backup_file => ""
}

module TwitterBackup
  class TBConfig
    class << self
      def load
        TwitterBackup.prepare_file config_file
        yaml = YAML::load_file( config_file )
        @@options = if yaml.is_a? Hash
          CONFIG_DEFAULTS.merge(yaml)
        else
          CONFIG_DEFAULTS
        end
      end

      def save options
        @@options = options
        TwitterBackup.prepare_file config_file
        File.open( config_file, "w" ){|f| YAML::dump( options, f )}
      end

      def options
        @@options ||= load
      end

      def credentials_missing?
        say ".... checking existance of credentials" if passed_opts.verbose?
        options[:credentials].values.map(&:strip).include? ""
      end

      def path_to_backup_defined?
        options[:backup_file].present?
      end

      def save_backup_file file
        options[:backup_file] = file
        save options
      end

      def save_credentials new_credentials
        options[:credentials] = options[:credentials].merge(new_credentials)
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
            t.text :raw
          end
        end
      end

      def configure_twitter_gem
        raise MissingCredentials if credentials_missing?
        Twitter.configure do |config|
          config.consumer_key = options[:credentials][:consumer_key]
          config.consumer_secret = options[:credentials][:consumer_secret]
          config.oauth_token = options[:credentials][:oauth_token]
          config.oauth_token_secret = options[:credentials][:oauth_token_secret]
        end
        @@twitter_gem_configured = true
      end

      def check_backup_file
        begin 
          backup_file = File.expand_path(options[:backup_file])
          TwitterBackup.prepare_file( backup_file ) unless File.exist?( backup_file )
        rescue Exception => e
          raise Error::InvalidBackupFile, e.message
        end
      end

      def configure
        say ".... configuring database" if passed_opts.verbose?
        configure_database

        say ".... configuring twitter gem" if passed_opts.verbose?
        configure_twitter_gem

        say ".... checking backup file: #{options[:backup_file]}" if passed_opts.verbose?
        check_backup_file
      end

      def verify_credentials
        say ".... checking validity of credentials" if passed_opts.verbose?
        configure_twitter_gem unless @@twitter_gem_configured
        @@user = Twitter.verify_credentials(:skip_status => true, :include_entities => false)
      end

      def user
        @@user ||= verify_credentials
      end

      def config_file
        passed_opts[:config] || CONFIG_FILE
      end

      def passed_opts 
        @@opts ||= Slop.parse(:help => true) do
          on :v, :verbose, 'Enable verbose mode'
          on :f, :force, "Try to download tweets, even it seems useless"
          on :s, :seed, "Try to download tweets older then the oldest one you have"
          on :c, :config, "Config file. Default: #{CONFIG_FILE}"
        end
      end

    end
  end
end