$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'multi_distinct_logger'

require 'minitest/autorun'

module TestHelper
  include MultiDistinctLogger

  def log_file_path(file_name)
    log_dir + "/#{file_name}"
  end

  def distinct_log_file_path(program, level)
    log_dir + "/#{program.to_s}/#{level.downcase}.log"
  end

  def setup
    MDLogger.disable_distinct_logger = false
    MDLogger.distinct_level_programs = []
    MDLogger.distinct_log_directory = '/tmp'
    MDLogger.distinct_log_attributes = [:level, :formatter]
    dir = log_dir
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
  end

  def teardown
    delete_test_logs
  end

  def delete_test_logs
    FileUtils.rm_rf(Dir.glob(File.expand_path('log/*', File.dirname(__FILE__))))
  end

  def assert_log_lines_count(file_path, lines_count)
    file = File.open(file_path, 'r')
    file_lines_size = file.readlines.size
    assert file_lines_size == lines_count, "invalud log(#{file_path}) lines count #{file_lines_size == lines_count }"
    file.close
  end
end

def log_dir
  "#{File.dirname(__FILE__)}/log"
end

Minitest.after_run {
  FileUtils.rm_rf(log_dir)
}


