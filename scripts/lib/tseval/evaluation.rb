require_relative 'edm'

require 'benchmark'
require 'csv'
require 'timeout'

module TSEval
  
  module Evaluation
    include EDM
    
    # runs the evaluation procedure
    def evaluate
      
      ingest_timeout = @ts_config["evaluation"]["ingest_timeout"]
      query_timeout = @ts_config["evaluation"]["query_timeout"]
      
      # a pool of sample data contained in the datafiles (used for queries)
      @data_pool = Hash.new{|h, k| h[k] = []}
      
      # prepare the output_file, reset the store and run the evaluation
      CSV.open(@output_file, "wb") do |csv|
        
          csv.sync = true
          
          # append the CSV heder entries
          csv << ["iteration", "file", "triples", "loadTime", "query1", "query2"]
          
          @runs.times do |iteration|
            
            # reset the triple store
            reset
            
            # run the experiments for each data file
            @data_files.sort.each do |file|
              
              # add sample data from data_file to datapool; count triples
		          triples = build_data_pool(file)

              # -- measure INGEST TIME --
              loadTime = -1
              begin
                status = Timeout::timeout(ingest_timeout) {
                  loadTime = Benchmark.realtime { ingest_triples(file) }
                }
              rescue Timeout::Error => e
                puts "Ingest exceeded timeout; stopping evaluation"
                break
                # jump out of the loop
              end
              

              # -- measure DESCRIBE QUERY TIME --
              random_aggr = @data_pool[:aggr].shuffle[0]
              describe_query = "DESCRIBE <#{random_aggr}>"
              query1 = -1
              begin
                status = Timeout::timeout(query_timeout) {
                 query1 = Benchmark.realtime {execute_query(describe_query)}
                }
              rescue Timeout::Error => e
                puts "Query exceeded timeout; stopping evaluation"
                break
                # jump out of the loop
              end
              
              
              # -- measure LANDING_PAGE QUERY TIME --
              random_lp = @data_pool[:landing_pages].shuffle[0]
              select_query = "SELECT ?x WHERE {?x #{EDM_LANDINGPAGE} <#{random_lp}>}"
              query2 = -1
              begin
                status = Timeout::timeout(query_timeout) {
                  query2 = Benchmark.realtime {execute_query(select_query)}
                }
              rescue Timeout::Error => e
                puts "Query exceeded timeout; stopping evaluation"
                break
                # jump out of the loop
              end
              
              result = [iteration, file, triples, loadTime.round(2), query1.round(2), query2.round(2)]
              
              # output the result for debug purposes
              puts result
              
              # write the result to the CSV file
              csv << result
              
            end # end of each
            
            # shutdown the triple store
            shutdown
            
          end # end of x.times
          
      end #end of output_file
      
    end
    
private
    
    # caches some sample data from a given data_file; returns the total number of triples in the file
    def build_data_pool(file)
      counter = 0
      File.open(file, "r") do |file|
        while line = file.gets
          
          counter = counter + 1
          
          # extract subject[0]/predicate[1]/object[2], drop "."
          spo = line.split

          # find edm aggregations
          if spo[1] == RDF_TYPE and spo[2] == EDM_AGGREGATION
            edm_aggr = spo[0][1..-2]
            # add 1% of all found aggregations to data pool
            @data_pool[:aggr] << edm_aggr if (1..100).to_a.shuffle[0] == 1
          end
          
          # find the landing pages
          if spo[1] == EDM_LANDINGPAGE
            landing_page = spo[2][1..-2]
            # add 1% of all found landing pages to data pool
            @data_pool[:landing_pages] << landing_page if (1..100).to_a.shuffle[0] == 1
          end
        end
      end
      puts "Test data pool -- Aggregations: #{@data_pool[:aggr].size} | Landing pages: #{@data_pool[:landing_pages].size}"
      return counter
    end
    
  end
  
end
