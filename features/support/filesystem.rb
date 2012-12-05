require 'fileutils'

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
  #
  # @api public
  def run(command)
    in_current_dir do
      # stdout, stderr pipes
      rout, wout = IO.pipe
      rerr, werr = IO.pipe

      pid = Process.spawn(command, :out => wout, :err => werr)
      _, status = Process.wait2(pid)

      # close write ends so we could read them
      wout.close
      werr.close

      @stdout = rout.readlines.join("\n")
      @stderr = rerr.readlines.join("\n")

      # dispose the read ends of the pipes
      rout.close
      rerr.close

      @last_exit_status = status.exitstatus
    end
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

end
