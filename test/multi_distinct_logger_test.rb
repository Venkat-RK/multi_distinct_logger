require 'test_helper'

class MultiDistinctLoggerTest < Minitest::Test
  include TestHelper

  def test_that_it_has_a_version_number
    refute_nil ::MultiDistinctLogger::VERSION
  end

  def test_default_class_attr_accessors
    assert MDLogger.disable_distinct_logger == false
    assert MDLogger.distinct_level_programs == []
    assert MDLogger.distinct_log_directory == '/tmp'
    assert MDLogger.distinct_log_attributes == [:level, :formatter]
  end

  def test_default_class_attr_accessors
    MDLogger.disable_distinct_logger= true
    MDLogger.distinct_level_programs= []
    MDLogger.distinct_log_directory= '/tmp/test'
    MDLogger.distinct_log_attributes= [:level]

    assert MDLogger.disable_distinct_logger == true
    assert MDLogger.distinct_level_programs == []
    assert MDLogger.distinct_log_directory == '/tmp/test'
    assert MDLogger.distinct_log_attributes == [:level]
  end

  def test_add_distinct_level_programs
    MDLogger.distinct_level_programs= ['test']
    MDLogger.add_distinct_level_program(:test2)
    assert MDLogger.distinct_level_programs == ['test', 'test2']
  end

  def test_add_distinct_log_attributes
    MDLogger.distinct_log_attributes= [:test]
    MDLogger.add_distinct_log_attribute(:test2)
    assert MDLogger.distinct_log_attributes == [:test, :test2]
  end

  def test_mdlogger_initialize
    log_file1 = log_file_path "test.log"
    logger1 = Logger.new(log_file1)
    md_logger = MDLogger.new(:loggers => [logger1])
    assert md_logger.class.to_s == 'MultiDistinctLogger::MDLogger', "Invalid class name #{md_logger.class.to_s}"
  end

  def test_mulitple_logging
    log_file1 = log_file_path "test.log"
    log_file2 = log_file_path "test1.log"
    logger1 = Logger.new(log_file1)
    logger2 = Logger.new(log_file2)
    md_logger = MDLogger.new(:loggers => [logger1, logger2])

    assert File.exists?(log_file1), "log file : #{log_file1} not found"
    assert File.exists?(log_file2), "log file : #{log_file2} not found"
    log_file1_size = File.size(log_file1)
    log_file2_size = File.size(log_file2)

    assert md_logger.class.to_s == 'MultiDistinctLogger::MDLogger', "Invalid class name #{md_logger.class.to_s}"
    md_logger.info("It's test info")
    md_logger.info("It's test info")

    assert File.exists?(log_file1), "log file : #{log_file1} not found"
    assert File.exists?(log_file2), "log file : #{log_file2} not found"

    assert log_file1_size < File.size(log_file1)
    assert log_file2_size < File.size(log_file2)
  end

  def test_distinct_logging
    MDLogger.distinct_level_programs= ['sub_log']
    MDLogger.distinct_log_directory = log_dir

    log_file1 = log_file_path "test.log"
    logger1 = Logger.new(log_file1)
    logger1.level= Logger::INFO
    logger1.progname= 'sub_log'

    distinct_log_file = distinct_log_file_path(logger1.progname, 'INFO')

    md_logger = MDLogger.new(:loggers => [logger1])
    assert File.exists?(log_file1), "log file : #{log_file1} not found"
    log_file1_size = File.size(log_file1)

    assert md_logger.class.to_s == 'MultiDistinctLogger::MDLogger', "Invalid class name #{md_logger.class.to_s}"
    md_logger.info("It's test info")
    md_logger.warn("It's test warning!!")

    assert File.exists?(log_file1), "log file : #{log_file1} not found"
    assert File.exists?(distinct_log_file), "log file : #{distinct_log_file} not found"

    assert log_file1_size < File.size(log_file1)
  end

  def test_multiple_distict_logging
    MDLogger.distinct_level_programs= ['sub_log1', 'sub_log2']
    MDLogger.distinct_log_directory = log_dir

    log_file1 = log_file_path "test.log"
    log_file2 = log_file_path "test1.log"

    logger1 = Logger.new(log_file1)
    logger1.level= Logger::DEBUG
    logger1.progname= 'sub_log1'

    logger2 = Logger.new(log_file2)
    logger2.level= Logger::WARN
    logger2.progname= 'sub_log2'

    md_logger = MDLogger.new(:loggers => [logger1, logger2])

    assert File.exists?(log_file1), "log file : #{log_file1} not found"
    assert File.exists?(log_file2), "log file : #{log_file2} not found"

    log_file1_size = File.size(log_file1)
    log_file2_size = File.size(log_file2)

    assert md_logger.class.to_s == 'MultiDistinctLogger::MDLogger', "Invalid class name #{md_logger.class.to_s}"

    md_logger.info("It's test info")
    md_logger.warn("It's test warning!!")
    md_logger.debug("It's test Debuging!!")

    assert File.exists?(log_file1), "log file : #{log_file1} not found"
    assert File.exists?(log_file2), "log file : #{log_file2} not found"

    assert File.exists?(distinct_log_file_path(logger1.progname, 'INFO')), "log file : #{distinct_log_file_path(logger1.progname, 'INFO')} not found"
    assert File.exists?(distinct_log_file_path(logger1.progname, 'WARN')), "log file : #{distinct_log_file_path(logger1.progname, 'WARN')} not found"
    assert File.exists?(distinct_log_file_path(logger1.progname, 'DEBUG')), "log file : #{distinct_log_file_path(logger1.progname, 'DEBUG')} not found"

    assert File.exists?(distinct_log_file_path(logger2.progname, 'INFO')), "log file : #{distinct_log_file_path(logger2.progname, 'INFO')} not found"
    assert File.exists?(distinct_log_file_path(logger2.progname, 'WARN')), "log file : #{distinct_log_file_path(logger2.progname, 'WARN')} not found"
    assert File.exists?(distinct_log_file_path(logger2.progname, 'DEBUG')), "log file : #{distinct_log_file_path(logger2.progname, 'DEBUG')} not found"

    assert_log_lines_count(distinct_log_file_path(logger1.progname, 'INFO'), 2)
    assert_log_lines_count(distinct_log_file_path(logger1.progname, 'WARN'), 2)
    assert_log_lines_count(distinct_log_file_path(logger1.progname, 'DEBUG'), 2)
    assert_log_lines_count(distinct_log_file_path(logger2.progname, 'WARN'), 2)
    assert_log_lines_count(distinct_log_file_path(logger2.progname, 'INFO'), 1)
    assert_log_lines_count(distinct_log_file_path(logger2.progname, 'DEBUG'), 1)

    assert File.exists?(log_file1), "log file : #{log_file1} not found"
    assert File.exists?(log_file2), "log file : #{log_file2} not found"

    assert log_file1_size < File.size(log_file1)
  end

end
