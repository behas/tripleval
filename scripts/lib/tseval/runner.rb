require_relative 'options'
require_relative 'triplestore'
require_relative '4store'
require_relative 'virtuoso'
require_relative 'jenaSDB'
require_relative 'jenaTDB'
require_relative 'virtuoso'
require_relative 'sesame'

module TSEval
  
  class Runner
  
    def initialize(argv)
      @options = Options.new(argv).options
      @argv = argv
    end
    
    def run
      
      if @options[:triplestore] == nil
        puts "Please define the triplestore(s) to be evaluated using the -s option!"
      else
        # dynamically load the triple store class defined by the -s parameter
        ts_class_name = @options[:triplestore]
        ts_class_name = ts_class_name[ts_class_name.rindex(":")+1..-1]
        
        unless TSEval.const_defined?(ts_class_name)
          puts "Please make sure that class #{ts_class_name} is included in runner.rb"
          exit(-1)
        end
        
        # instantiate the triple store
        ts_class = TSEval.const_get(ts_class_name)
        ts = ts_class.new(@options, @argv)
        
        # start the evaluation
        ts.evaluate
        
      end
      
    end
    
  end
  
end