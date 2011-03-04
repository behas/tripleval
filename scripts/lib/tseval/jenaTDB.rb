require_relative 'triplestore'
require 'fileutils'

module TSEval
  
  class JenaTDB < Triplestore
    
    def initialize(options, data_files)
      super(options, data_files)
      
      @root = @ts_config["jenaTDB"]["root"]
      @db_config = @ts_config["jenaTDB"]["db_config"]
      @db_path = @ts_config["jenaTDB"]["db_path"]
      
      puts "Initalizing Jena TDB triple store..."

      ENV['TDBROOT'] ||= @root
      ENV['CLASSPATH'] ||= @root + "/lib/TDB-0.8.9.jar"
      ENV['PATH'] = "#{ENV['TDBROOT']}/bin:#{ENV['PATH']}"
      
      puts "Setting DB-path in #{@db_config}"
      orig_file = File.read(@db_config)
      File.open(@db_config, "w") {|file| file.puts orig_file.gsub(/tmp/, @db_path)}
    end
    
    # reset and prepare the triple store for import
    def reset
       puts "Deleting the database directory at #{@db_path}"
       FileUtils.rm_rf(@db_path)
    end
    
    # shutdown the triples store
    def shutdown
      reset
    end
    
    # imports a given triple file and returns the ingest time
    def ingest_triples(data_file)
      puts "Ingesting #{data_file} into Jena TDB..."
      response = `#{@root}/bin/tdbloader --tdb #{@db_config} #{data_file}`
      puts response if @verbose
    end
    
    # executes the given SPARQL query
    def execute_query(sparql_query)
      puts "Executing SPARQL Query: #{sparql_query} ..."
      response = `#{@root}/bin/tdbquery --tdb #{@db_config} '#{sparql_query}'`
      puts response if @verbose
    end
    
  end # end of class JenaTDBStore
  
end # end of module
