require_relative 'triplestore'

module TSEval
  
  class FourStore < Triplestore
    
    def initialize(options, data_files)
      super(options, data_files)
      
      puts "Initalizing 4Store..."
      
      @kb = @ts_config["4store"]["kb_name"]
    end
    
    # reset and prepare the triple store for import
    def reset
      
      shutdown
      
      puts "Destroying the Europeana KB..."
      `4s-backend-destroy #{@kb}`
      
      puts "Creating a new Europeana KB..."
      `4s-backend-setup #{@kb}`
      
      puts "Starting the Europeana KB..."
      `4s-backend #{@kb}`

    end
    
    # shutdown the triples store
    def shutdown
      
      puts "Killing existing 4store KB processes..."
      `pkill -f '4s-backend #{@kb}'`
      
    end
    
    # imports a given triple file and returns the ingest time
    def ingest_triples(data_file)
      
      puts "Ingesting #{data_file} into 4Store..."
      `4s-import #{@kb} #{data_file}`
      
    end
    
    # executes the given SPARQL query
    def execute_query(sparql_query)
      
      puts "Executing SPARQL Query: #{sparql_query} ..."
      response = `4s-query #{@kb} '#{sparql_query}'`
      puts response if @verbose
      
    end
    
  end # end of class FourStore
  
end # end of module