require 'benchmark'
require File.dirname(__FILE__) + '/../lib/db_mlp'
  
db = File.dirname(File.expand_path(__FILE__)) + "/data.txt"

training = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
testing = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
validation = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]

Benchmark.bm do |x|
  x.report do
    a = DBMLP.new(db, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)
    a.train(training, testing, validation, 3000)
  end
end
