require "yaml"
require "fileutils"
require "highline/import"
require 'active_support/core_ext/string'
require "twitter"
require_relative "twitter_backup/version"
require_relative "twitter_backup/config"
require_relative "twitter_backup/tweat"

module TwitterBackup
  def self.prepare_file file
    file = File.expand_path file
    dir = File.dirname file
    FileUtils.mkdir_p dir unless File.exist? dir
    FileUtils.touch file unless File.exist? file
  end
end

unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end
class File
  def tail(n)
    buffer = 1024
    idx = (size - buffer).abs
    chunks = []
    lines = 0
    begin
      seek(idx)
      chunk = read(buffer)
      lines += chunk ? chunk.count("\n") : 0
      chunks.unshift chunk
      idx -= buffer
    end while lines < ( n + 1 ) && pos != 0
    tail_of_file = chunks.join('')
    ary = tail_of_file.split(/\n/)
    lines_to_return = ary[ ary.size - n, ary.size - 1 ] || []
  end
end