require 'fileutils'
require 'open4'

module Filesystem
  def write_file(filename, contents)
    in_current_dir do
      mkdir(File.dirname(filename))
      File.open(filename, 'w') { |f| f << contents }
    end
  end

  def in_current_dir(&block)
    mkdir(current_dir)
    Dir.chdir(current_dir, &block)
  end

  def current_dir
    File.join(*dirs)
  end

  def dirs
    ['tmp/fs']
  end

  def run(command)
    in_current_dir do
      pid = Open4.popen4(command) do |pid, stdin, stdout, stderr|
        @stdout = stdout.readlines.join("\n")
        @stderr = stderr.readlines.join("\n")
      end
      @last_exit_status = pid.exitstatus
    end
  end

  def mkdir(dirname)
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
  end
end
