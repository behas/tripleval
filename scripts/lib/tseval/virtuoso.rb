require_relative 'triplestore'

module TSEval
  
  class Virtuoso < Triplestore
        
    def initialize(options, data_files)
      super(options, data_files)

      puts "Initalizing OpenLink Virtuoso..."
      @port = @ts_config["virtuoso"]["port"]
      @user = @ts_config["virtuoso"]["user"]
      @pass = @ts_config["virtuoso"]["pass"]
      @graph = @ts_config["virtuoso"]["graph"]
      
    end
    
    # reset and prepare the triple store for import
    def reset
      "Resetting Virtuoso..."
      response = `isql #{@port} #{@user} #{@pass} exec="RDF_GLOBAL_RESET ();"`
      puts response if @verbose
      "Committing..."
      response = `isql #{@port} #{@user} #{@pass} exec="checkpoint;"`
      puts response if @verbose
      response = `isql #{@port} #{@user} #{@pass} exec="log_enable(2);"`
      puts response if @verbose
    end
    
    # shutdown the triples store
    def shutdown
      "Please shutdown Virtuoso manually"
    end
    
    # imports a given triple file and returns the ingest time
    def ingest_triples(data_file)
      abs_file_path = File.absolute_path(data_file)
      
      puts "Ingesting #{abs_file_path} into Virtuoso..."
      response = `isql #{@port} #{@user} #{@pass} exec="DB.DBA.TTLP_MT_LOCAL_FILE('#{abs_file_path}', '', '#{@graph}', 255);"`
      puts response if @verbose
    end
    
    # executes the given SPARQL query
    def execute_query(sparql_query)
      puts "Executing SPARQL Query: #{sparql_query} ..."
      response = `isql #{@port} #{@user} #{@pass} exec="SPARQL #{sparql_query}";`
      puts response if @verbose
    end
    
  end # end of class FourStore
  
end # end of module
