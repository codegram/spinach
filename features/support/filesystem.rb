require 'fileutils'
require 'open3'

# The Filesystem module runs commands, captures their output and exit status
# and lets the host know about it.
#
module Filesystem
  def self.dirs
    ['tmp/fs']
  end

  # Writes a file with some contents.
  #
  # @param [String] filename
  #   The file name to write.
  #
  # @param [String] contents
  #   The contents to include in the file.
  #
  # @api public
  def write_file(filename, contents)
    in_current_dir do
      mkdir(File.dirname(filename))
      File.open(filename, 'w') { |f| f << contents }
    end
  end

  # Executes a code block within a particular directory.
  #
  # @param [Proc] block
  #   The block to execute
  #
  # @api public
  def in_current_dir(&block)
    mkdir(current_dir)
    Dir.chdir(current_dir, &block)
  end

  # Runs a command in the current directory.
  #
  # It populates the following instance variables:
  #
  #   * @stdout - The standard output captured from the process.
  #   * @stderr - The standard error captured from the process.
  #   * @last_exit_status - The process exit status.
  #
  # @param [String] command
  #   The command to run.
  # @param [Hash] env
  #   Hash of environment variables to use with command
  #
  # @api public
  def run(command, env = nil)
    in_current_dir do
      args = command.strip.split(" ")
      args = args.unshift(env) if env
      @stdout, @stderr, @last_exit_status = Open3.capture3(*args)
    end

    @stdout = strip_colors(@stdout)
    @stderr = strip_colors(@stderr)
  end

  private

  def mkdir(dirname)
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
  end

  def rmdir(dirname)
    FileUtils.rm_rf(dirname) unless File.directory?(dirname)
  end

  def current_dir
    File.join(*dirs)
  end

  def dirs
    ['tmp/fs']
  end

  def strip_colors(string)
    string.gsub(/\e\[((\d;?)+)m/, "")
  end
end
