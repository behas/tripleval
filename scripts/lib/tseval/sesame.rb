require_relative 'triplestore'
require 'ruby-sesame' 


module TSEval
  
  class Sesame < Triplestore
    
    def initialize(options, data_files)
      super(options, data_files)

      url = @ts_config["sesame"]["url"]
      repository = @ts_config["sesame"]["repository"]
      server = RubySesame::Server.new(url, true)
      @repository = server.repository(repository)

    end
    
    # reset and prepare the triple store for import
    def reset
      puts "Number of statements in the repository: " + @repository.size.to_s
      puts "Resetting Sesame..."
      @repository.delete_all_statements!
      puts "Number of statements in the repository: " + @repository.size.to_s
    end
    
    # shutdown the triples store
    def shutdown
      "Please shutdown Tomacat server manually"
    end
    
    # imports a given triple file and returns the ingest time
    def ingest_triples(data_file)
      puts "Ingesting #{data_file} into Sesame..."

      nt_file = File.read(data_file)
      @repository.add!(nt_file)
    end
    
    # executes the given SPARQL query
    def execute_query(sparql_query)
      puts "Executing SPARQL Query: #{sparql_query} ..."
      
      if sparql_query.include? "DESCRIBE"
        response = @repository.query(sparql_query, :result_type => RubySesame::DATA_TYPES[:N3])  
        puts response if @verbose
      end

      if sparql_query.include? "SELECT" 	
         response = @repository.query(sparql_query)	
         puts response if @verbose
      end

    end
    
  end # end of class SesameStore
  
end # end of module
