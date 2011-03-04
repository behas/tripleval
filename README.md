# Europeana RDF Store Performance Test Suite

The purpose of this test suite is to evaluate the performance of various existing RDF store solutions w.r.t to data ingest and SPARQL querying.

It provides a generic evaluation procedure, which is executed against a given set of triple stores. At the moment it supports the following stores:

* [4Store](http://4store.org/ "4Store")
* [OpenLink Virtuoso](http://virtuoso.openlinksw.com/dataspace/dav/wiki/Main/ "OpenLink Virtuoso")
* [JenaSDB](http://openjena.org/wiki/SDB/ "Jena SDB")
* [JenaTDB](http://openjena.org/wiki/TDB/ "Jena TDB")
* [Sesame](http://www.openrdf.org/ "Openrdf Sesame")


## Prerequisites

The RDF stores must be installed on the system where the test suite is executed. Make sure the commands defined in the triple store wrapper classes are executable on the command line.

The datasets used for the evaluation must be available in N-Triple serialization and should be split into equally sized blocks in order to evaluate performance on various load levels. I included some sample files in the _test_ directory.

The following scripts assume that these N-Triple files reside in a `data` subdirectory

## Triple Store specific configurations

### Jena TDB

Make sure that you have set your system-specific configurations, e.g.,:

    jenaTDB:
      root: /Users/someuser/TDB-0.8.9/
      db_config: /Users/someuser/TDB-0.8.9/Store/tdb-assembler.ttl
      db_path: /Users/someuser/stores/TDB-0.8.9/db

Start the evaluation using the following command:

    ruby -I lib/ bin/tseval -r 3 -v -s TSEVal::JenaTDB -o ../results/jenaTDB.csv ../data/*.nt

### Jena SDB

Start-up your local MySQL instance, login as root (`mysql -u root -p`) and 

* create a database _SDB2_: `create database SDB2`
* create a user _jenaSDB_: `create user 'jenaSDB'@'localhost'`
* assign full database privileges to this user on this database: `grant all on sdb2.* TO 'jenaSDB'@'localhost';`

Make sure that you have set your system-specific configurations, e.g.,:

    jenaSDB:
      root: /Users/someuser/SDB-1.3.3
      db_config: /Users/someuser/SDB-1.3.3/Store/sdb.ttl
      db_config_template: /Users/someuser/SDB-1.3.3/Store/sdb-mysql-innodb.ttl
      db_jdbc: /Users/someuser/SDB-1.3.3/mysql-connector-java-5.1.14-bin.jar
      db_name: sdb2
      db_host: localhost
      db_user: username
      db_pass: password

Start the evaluation using the following command:

    ruby -I lib/ bin/tseval -r 3 -v -s TSEVal::JenaSDB -o ../results/jenaSDB.csv ../data/*.nt
    
### Sesame 

Follow the Sesame set-up and installation instructions, make sure that it running (e.g., http://localhost:8080/openrdf-sesame/) and create a repository for storing the RDF data. For evaluating Sesame you also need to install the `ruby-sesame` gem.

Make sure that you have set your system-specific configurations, e.g.,:

    sesame:
      url: http://localhost:8080/openrdf-sesame/
      repository: europeana


Install the `ruby-sesame gem`

    gem install ruby-sesame


Start the evaluation using the following command:

    ruby -I lib/ bin/tseval -r 3 -v -s TSEVal::Sesame -o ../results/Sesame.csv ../data/*.nt


## OpenLink Virtuoso

Make sure that Virtuoso is up and running on your system and that you have set the following configuration parameters:

    virtuoso:
      port: 1111
      user: username
      pass: password
      graph: http://europeana.eu


Start the evaluation using the following command:
      
      ruby -I lib/ bin/tseval -v -r 3 -s TSEval::Virtuoso -o ../results/Virtuoso.csv ../data/*.nt

---

## Analyzing the results with R

You can use the [R](http://www.r-project.org/) script provided in the _result_ folder. Just make sure that the script knows all the .csv files you want to included in the result analysis. Check the following line

    result_files <- c("4store.csv", "Virtuoso.csv", "JenaTDB.csv", "JenaSDB.csv")
    
And: you must install the _ggplot2_ R package first...


## Other useful stuff:

Split one big N-TRIPLES file into smaller parts using the following command:

    split -l NO_TRIPLES big_file.nt small_files_prefix

Bulk append .nt suffix to split N-Triple files:

    ls * | awk '{printf "mv %s %s.nt \n", $1, $1}' | /bin/sh