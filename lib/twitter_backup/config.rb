
CONFIG_DIR = File.expand_path(File.join("~/", ".config", "twitter_backup"))
CONFIG_FILE = File.join(CONFIG_DIR, "config.yml")

CONFIG_DEFAULTS = {
  :CREDENTIALS => {
    :consumer_key => "",
    :consumer_secret => "",
    :oauth_token => "",
    :oauth_token_secret => "",
    :username => ""
  },
  :backup_file => File.join(CONFIG_DIR, "tweats"),
  :initial_seeded => false
}

module TwitterBackup
  class Config
    def self.load
      FileUtils.mkdir_p( CONFIG_DIR ) unless File.exist? CONFIG_DIR
      FileUtils.touch( CONFIG_FILE ) unless File.exist? CONFIG_FILE
      yaml = YAML::load_file( CONFIG_FILE )
      @@options = if yaml.is_a? Hash
        CONFIG_DEFAULTS.merge(YAML::load_file( CONFIG_FILE ))
      else
        CONFIG_DEFAULTS
      end
    end

    def self.save options
      @@options = options
      FileUtils.mkdir_p( CONFIG_DIR ) unless File.exist? CONFIG_DIR
      FileUtils.touch( CONFIG_FILE ) unless File.exist? CONFIG_FILE
      File.open( CONFIG_FILE, "w" ) do |f|
        YAML::dump( options, f )
      end
    end

    def self.options
      @@options ||= self.load
    end

  end
end