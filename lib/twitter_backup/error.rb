module TwitterBackup
  module Error
    class InvalidPath < StandardError; end
    class InvalidBackupFile < StandardError; end
    class MissingCredentials < StandardError; end
  end
end