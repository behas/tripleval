require_relative 'triplestore'
require 'fileutils'
require 'mysql2'


module TSEval
  
  class JenaSDB < Triplestore
    
    def initialize(options, data_files)
      super(options, data_files)
      
      @root = @ts_config["jenaSDB"]["root"]

      @db_name = @ts_config["jenaSDB"]["db_name"]
      @db_host = @ts_config["jenaSDB"]["db_host"]
      @db_user = @ts_config["jenaSDB"]["db_user"]
      @db_pass = @ts_config["jenaSDB"]["db_pass"]
      @db_jdbc = @ts_config["jenaSDB"]["db_jdbc"]
      
      @db_config = @ts_config["jenaSDB"]["db_config"]
      db_config_template = @ts_config["jenaSDB"]["db_config_template"]      
      
      puts "Setting Jena SDB environment variables..."
	    ENV['SDBROOT'] ||= @root
	    ENV['SDB_JDBC'] ||= @db_jdbc
      ENV['SDB_USER'] ||= @db_user
      ENV['SDB_PASSWORD'] ||= @db_pass
      ENV['CLASSPATH'] ||= "#{@sdb_root}/lib/sdb-1.3.3.jar"
      ENV['PATH'] = "#{ENV['SDBROOT']}/bin:#{ENV['PATH']}"
                  
      puts "Making #{db_config_template} the configuration file."
      FileUtils.cp(db_config_template, @db_config)
      
      puts "Setting database name in #{@db_config}"
      orig_file = File.read(@db_config)
      File.open(@db_config, "w") {|file| file.puts orig_file.gsub(/sdb:sdbName\s*"\w*"\s*;/, "sdb:sdbName\t\t\t\t\"#{@db_name}\" ;")}
      
    end
    
    # reset and prepare the triple store for import
    def reset
      puts "Resetting Jena SDB..."
      
      drop_database
      create_database
      
      response = `#{@root}/bin/sdbconfig --sdb #{@db_config} --create`
      puts response if @verbose
    end
    
    # shutdown the triples store
    def shutdown
      drop_database
    end
    
    # imports a given triple file and returns the ingest time
    def ingest_triples(data_file)
      puts "Ingesting #{data_file} into Jena..."
      response = `#{@root}/bin/sdbload --sdb #{@db_config} #{data_file}`
      puts response if @verbose
    end
    
    # executes the given SPARQL query
    def execute_query(sparql_query)
      puts "Executing SPARQL Query: #{sparql_query} ..."
      response = `#{@root}/bin/sdbquery --sdb #{@db_config} '#{sparql_query}'`
      puts response if @verbose
    end
    
  private
  
    # creates the mysql database
    def create_database
      puts "Creating database #{@db_name}..."
      begin
        client = Mysql2::Client.new(:host => @db_host, :username => @db_user, :password => @db_pass)
        client.query("CREATE DATABASE #{@db_name}")
        client.close
      rescue Exception => e
        puts "An error occurred\n #{e}"
      end
    end
    
    # drops the mysql database (if it exists)
    def drop_database
      puts "Droping database #{@db_name}..."
      begin
        client = Mysql2::Client.new(:host => @db_host, :username => @db_user, :password => @db_pass)
        client.query("DROP DATABASE IF EXISTS #{@db_name}")
        client.close
      rescue Exception => e
        puts "An error occurred\n #{e}"
      end
    end
    
  end # end of class JenaSDBStore
  
end # end of module
