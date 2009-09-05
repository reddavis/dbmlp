require File.dirname(__FILE__) + '/../lib/mlp'
require 'rubygems'
require 'ruby-prof'

db = "sqlite3://#{File.dirname(File.expand_path(__FILE__))}/../benchmarks/data.rdb"

a = DBMLP.new(db, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)

@training = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
@testing = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
@validation = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]

result = RubyProf.profile do
  a = a.train(@training, @testing, @validation, 100)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, 0)