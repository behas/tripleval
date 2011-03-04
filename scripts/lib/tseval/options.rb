require 'optparse'
require_relative 'triplestore'

module TSEval

  class Options

      DEFAULT_OUTPUT_FILE = "results.csv"
      DEFAULT_CONFIG_FILE = "conf/ts_config.yml"
      DEFAULT_VERBOSE = false
      DEFAULT_RUNS = 1
  
      attr_reader :options
  
      def initialize(argv)
        @options = {}
        @options[:output_file] = DEFAULT_OUTPUT_FILE
        @options[:config_file] = DEFAULT_CONFIG_FILE
        @options[:verbose] = DEFAULT_VERBOSE
        @options[:runs] = DEFAULT_RUNS
        parse(argv)
      end
  
      private
  
      def parse(argv)
    
        optParser = OptionParser.new do |opts|
          opts.banner = "Usage: ruby -I lib bin/tseval [options] data_files (e.g., ../data/*.nt)"
      
          opts.on("-s", "--store TRIPLESTORE", "The TRIPLESTORE to be evaluated #{Triplestore.subclasses}")  do |triplestore|
            @options[:triplestore] = triplestore
          end        
          
          opts.on("-o", "--output-file OUTPUT_FILE", String, "The result output file (e.g., #{DEFAULT_OUTPUT_FILE})") do |output_file|
            @options[:output_file] = output_file
          end

          opts.on("-c", "--config-file CONFIG_FILE", String, "The triple store configuration file (e.g., #{DEFAULT_CONFIG_FILE})") do |config_file|
            @options[:config_file] = config_file
          end
          
          opts.on("-r", "--runs RUNS", Integer, "The number of experiment runs (default: 1)") do |runs|
            @options[:runs] = runs
          end
      
          opts.on("-v", "--verbose", "Verbose triple store responses")  do |verbose|
            @options[:verbose] = verbose
          end        

          opts.on("-h", "--help", "Show this message") do
            puts opts
            exit
          end
        end
    
        begin
          argv = ["-h"] if argv.empty?
          optParser.parse!(argv)
        rescue Exception => e
          STDERR.puts e.message, "\n"
          exit(-1)
        end
    
      end #end of parse
  
  end # end of Options

end # end of TSEval
