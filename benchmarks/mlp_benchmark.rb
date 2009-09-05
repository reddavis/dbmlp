require 'rubygems'
require 'benchmarker'
require 'benchmark'
require File.dirname(__FILE__) + '/../lib/db_mlp'

Benchmarker.go('lib') do
  
  db = "sqlite3://#{File.dirname(File.expand_path(__FILE__))}/data.rdb"
  

  training = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
  testing = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
  validation = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
  
  Benchmark.bm do |x|
    x.report do
      a = DBMLP.new(db, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)
      a.train(training, testing, validation, 1000)
    end
  end

end