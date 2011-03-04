require_relative 'evaluation'
require 'yaml'

module TSEval
  
  class Triplestore
    include Evaluation
    
    # triple store specific attributes
    attr_accessor :verbose, :output_file, :runs, :config_file, :data_files
    
    # loads the YAML configuration file and makes its entries available to all subclasses
    def initialize(options, data_files)
      @verbose = options[:verbose]
      @output_file = options[:output_file]
      @runs = options[:runs]
      @data_files = data_files

      # Loading triple-store specific configuration
      @ts_config = YAML.load_file(options[:config_file].to_s)

    end
    
    # returns all subclasses of this class (need for reflective instantiaton)
    def self.subclasses
        ObjectSpace.each_object(Class).select { |klass| klass < self }
    end
    
  end # end of class Triplestore
  
end # end of module