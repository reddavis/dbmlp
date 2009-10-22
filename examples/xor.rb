require File.dirname(__FILE__) + '/../lib/db_mlp'
require 'benchmark'

db = "sqlite3://#{File.dirname(File.expand_path(__FILE__))}/data.rdb"
a = DBMLP.new(db, :hidden_layers => [2, 2], :output_nodes => 1, :inputs => 2)

times = Benchmark.measure do

  srand 1
  
  training = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
  testing = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
  validation = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
  
  a.train(training, testing, validation, 3001)
  
  puts "Test data"
  puts "[0,0] = > #{a.feed_forward([0,0]).inspect}"
  puts "[0,1] = > #{a.feed_forward([0,1]).inspect}"
  puts "[1,0] = > #{a.feed_forward([1,0]).inspect}"
  puts "[1,1] = > #{a.feed_forward([1,1]).inspect}"
  
end

puts "Elapsed time: #{times}"