require 'helper'

class TestDBMLP < Test::Unit::TestCase
  context "Testing Report" do
    setup do
      set_data_variables
      db_path = "sqlite3://#{File.dirname(File.expand_path(__FILE__))}/db/data.rdb"
      @test_results_path = File.dirname(File.expand_path(__FILE__)) + '/db/test_results.txt'
      a = DBMLP.new(db_path, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)
      a.train(@training, @testing, @validation, 1, @test_results_path)
    end
    
    should "create a test results .txt file" do
      assert File.exists?(@test_results_path)
    end
    
    should "contain some text" do
      File.open(@test_results_path, 'r+') do |file|
        assert !file.readlines.empty?
      end
    end
  end
  
  context "DBMLP Instance" do
    setup do
      set_data_variables
      @db_path = "sqlite3://#{File.dirname(File.expand_path(__FILE__))}/db/data.rdb"
    end
  
    should "contain 4 layers" do
      a = DBMLP.new(@db_path, :hidden_layers => [2, 2, 2], :output_nodes => 2, :inputs => 2)
      assert_equal 4, a.inspect.size
    end
    
    should "contain saved 3 layers" do
      DBMLP.new(@db_path, :hidden_layers => [2, 2], :output_nodes => 2, :inputs => 2)
      b = Neuron.all.map {|x| x.layer_index}.uniq.size
      assert_equal 3, b
    end
    
    should "contain 1 output node" do
      DBMLP.new(@db_path, :hidden_layers => [2], :output_nodes =>4, :inputs => 2)
      a = DBMLP.new(@db_path, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)
      assert_equal 1, a.inspect.last.size
    end

    should "feed forward and set all neurons last outputs" do
      a = DBMLP.new(@db_path, :hidden_layers => [2], :output_nodes => 2, :inputs => 2)
      a.feed_forward([0,1])
      b = a.inspect.inject([]) do |array, n|
        array << n.map {|x| x.last_output}
      end
      b.flatten!
      assert !b.include?(nil)
    end
      
    should "return an array after feed forward" do
      a = DBMLP.new(@db_path, :hidden_layers => [2], :output_nodes => 2, :inputs => 2)
      assert_kind_of Array, a.feed_forward([0,1])
    end
  
    should "save its neurons deltas" do
      a = DBMLP.new(@db_path, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)
      a.train(@training, @testing, @validation, 1)
      b = Neuron.all(:delta.not => nil)
      assert !b.empty?
    end
  
    should "save its output neurons weights" do
      a = DBMLP.new(@db_path, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)
      before = Neuron.first(:layer_index => -1).weights.inject([]) do |array, n|
        array << n
      end
    
      a.train(@training, @testing, @validation, 1)
      
      after = Neuron.first(:layer_index => -1).weights.inject([]) do |array, n|
        array << n
      end
      assert_not_equal before, after
    end
  
    should "update its hidden neurons weights" do
      a = DBMLP.new(@db_path, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)
      before = Neuron.first(:layer_index => 0).weights.inject([]) do |array, n|
        array << n
      end
    
      a.train(@training, @testing, @validation, 1)
      after = Neuron.first(:layer_index => 0).weights.inject([]) do |array, n|
        array << n
      end
      assert_not_equal before, after
    end
  end
    
  context "DB for a new mlp" do
    setup do
      db_path = "sqlite3://#{File.dirname(File.expand_path(__FILE__))}/db/data.rdb"
      @a = DBMLP.new(db_path, :hidden_layers => [2, 2], :output_nodes => 2, :inputs => 2)
    end
  
    should "save 6 neurons" do
      assert_equal 6, Neuron.count
    end
    
    should "save 2 hidden neurons in the first hidden layer" do
      assert_equal 2, Neuron.count(:layer_index => 0)
    end
  end

  context "Neuron" do
    setup do
      @db_path = "sqlite3://#{File.dirname(File.expand_path(__FILE__))}/db/data.rdb"
    end
  
    should "have 2 weights on output neuron" do
      a = DBMLP.new(@db_path, :hidden_layers => [1], :output_nodes => 1, :inputs => 2)
      assert_equal 2, a.inspect.last.last.weights.size
    end
    
    should "have saved 2 weights on output neuron" do
      a = DBMLP.new(@db_path, :hidden_layers => [1], :output_nodes => 1, :inputs => 2)
      assert_equal 2, Neuron.first(:layer_index => -1).weights.size
    end
    
    should "have 3 weights on output neuron" do
      a = DBMLP.new(@db_path, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)
      assert_equal 3, a.inspect.last.last.weights.size
    end
    
    should "have saved 3 weights on output neuron" do
      a = DBMLP.new(@db_path, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)
      assert_equal 3, Neuron.first(:layer_index => -1).weights.size
    end
    
    should "create a hidden neuron with 3 weights" do
      a = DBMLP.new(@db_path, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)
      assert_equal 3, a.inspect.first.last.weights.size
    end
  end
    
  private
  
  def set_data_variables
    @training = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
    @testing = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
    @validation = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
  end

end
