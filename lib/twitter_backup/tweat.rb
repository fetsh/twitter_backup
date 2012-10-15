module TwitterBackup
  class Tweat
    
    attr_reader :text, :id, :created_at, :user
    
    def self.all
      tweats = YAML::load_file(TwitterBackup::Config.options[:backup_file]) || []
    end

    def self.save tweats
      tweats.concat self.all
      File.open( TwitterBackup::Config.options[:backup_file], "w" ) do |f|
        YAML::dump( tweats, f )
      end
    end

    def self.latest
      filechunk = File.open( TwitterBackup::Config.options[:backup_file] ) do |f|
        lines = []
        11.times do
          line = f.gets || break
          lines << line
        end
        lines.unshift("---") unless /\A---\s*\z/ === lines[0]
        lines
      end.join
      tweats = YAML::load(filechunk) || []
      tweats.first
    end

    def self.first
      filechunk = File.open(TwitterBackup::Config.options[:backup_file]) do |f|
        last_lines = f.tail(10)
        last_lines.unshift("---") unless /\A---\s*\z/ === last_lines[0]
      end.join("\n")
      tweats = YAML::load(filechunk) || []
      tweats.last
    end

    def initialize tweat
      if tweat.is_a? Twitter::Tweet
        @text = tweat.text
        @id = tweat.id
        @created_at = tweat.created_at
        @user = tweat.user.screen_name
      else
        @text = @id = @created_at = @user = nil
      end
    end

    def == obj
      return false if obj.blank?
      if obj.respond_to?(:id)
        obj.id == self.id
      else
        super
      end
    end

  end
end