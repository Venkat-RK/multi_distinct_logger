require "multi_distinct_logger/version"
require 'logger'
require 'fileutils'

module MultiDistinctLogger
  class MDLogger

    class << self

      #Default values
      @@disable_distinct_logger = false
      @@distinct_level_programs = []
      @@distinct_log_directory = '/tmp'
      @@distinct_log_attributes = [:level, :formatter]

      #Class level getter and setter methods
      def disable_distinct_logger=(flag)
        @@disable_distinct_logger = flag
      end

      def disable_distinct_logger
        @@disable_distinct_logger
      end

      def distinct_logger_enabled?
        !MDLogger.disable_distinct_logger
      end

      #progname should be string
      def distinct_level_programs=(array)
        @@distinct_level_programs = array.collect {|e| e.to_s}
      end

      def add_distinct_level_program(program)
        @@distinct_level_programs << program.to_s
        @@distinct_level_programs.compact!
      end

      def distinct_level_programs
        @@distinct_level_programs
      end

      def distinct_log_directory=(name)
        @@distinct_log_directory = name
      end

      def distinct_log_directory
        @@distinct_log_directory
      end

      def distinct_log_attributes=(attributes)
        @@distinct_log_attributes = attributes.collect {|e| e.to_sym}
      end

      def distinct_log_attributes
        @@distinct_log_attributes
      end

      def add_distinct_log_attribute(attribute)
        @@distinct_log_attributes << attribute.to_sym
        @@distinct_log_attributes.compact!
      end

    end

    def initialize(args={})
      @loggers = []
      Array(args[:loggers]).each { |logger| add_logger(logger) }
    end

    def add_logger(logger)
      @loggers << logger
    end

    def close
      @loggers.map(&:close)
    end

    ::Logger::Severity.constants.each do |level|
      define_method(level.downcase) do |*args|
        @loggers.each { |logger| logger.send(level.downcase, args)
          if MDLogger.distinct_logger_enabled? && MDLogger.distinct_level_programs.include?(logger.progname)
            dir = "#{MDLogger.distinct_log_directory}/#{logger.progname.to_s}"
            FileUtils.mkdir_p(dir) unless File.directory?(dir)

            distinct_level_logger = ::Logger.new("#{dir}/#{level.downcase}.log")
            MDLogger.distinct_log_attributes.each do |attribute|
              setter_method = (attribute.to_s+"=").to_sym
              distinct_level_logger.send(setter_method, logger.send(attribute))
            end

            distinct_level_logger.send(level.downcase, args)
          end
        }
      end

      define_method("#{ level.downcase }?".to_sym) do
        @level <= Logger::Severity.const_get(level)
      end

    end
  end
end
