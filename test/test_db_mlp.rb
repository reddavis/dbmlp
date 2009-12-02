require 'helper'

class TestDBMLP < Test::Unit::TestCase  
  context "DBMLP Instance" do
    setup do
      set_data_variables
      @db_path = saved_db_path
    end
        
    should "contain 4 layers (including output layer)" do
      a = DBMLP.new(@db_path, :hidden_layers => [2, 2, 2], :output_nodes => 2, :inputs => 2)
      assert_equal 4, a.inspect.size
    end
    
    should "contain 1 output node" do
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
  
    should "set its neurons deltas" do
      a = DBMLP.new(@db_path, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)
      a.train(@training, @testing, @validation, 1)
      b = a.inspect.flatten.map {|x| x.delta}.delete_if {|x| !x.nil?}
      assert b.empty?
    end
  end
    
  context "Network Structure" do
    setup do
      @db_path = saved_db_path
    end
          
    should "have 3 weights on output neuron" do
      a = DBMLP.new(@db_path, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)
      assert_equal 3, a.inspect.last.last.weights.size
    end
    
    should "have saved 2 neurons on the first hidden layer" do
      a = DBMLP.new(@db_path, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)
      assert_equal 2, a.inspect[0].size
    end
  end
  
  context "Validations" do
    setup do
      $stdout = StringIO.new
      @db_path = saved_db_path
      set_data_variables 
    end
    
    should "validate every 1 iterations" do
      a = DBMLP.new(@db_path, :hidden_layers => [2], 
                              :output_nodes => 1, 
                              :inputs => 2,
                              :verbose => true,
                              :validate_every => 2)
                              
      a.train(@training, @testing, @validation, 4)
      output = $stdout.string.scan(/Validating/)
      assert_equal 2, output.size
    end
  end
  
  context "Testing Report" do
    setup do
      set_data_variables
      db_path = saved_db_path
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

  context "Testing Results Parser" do
    setup do
      @test_results = File.dirname(__FILE__) + '/db/test_results_test/results.txt'
    end

    should "return 100%" do
      result = DBMLP.parse_test_results(@test_results, 1)
      assert_equal 100, result
    end

    should "return 50%" do
      result = DBMLP.parse_test_results(@test_results, 0.00002)
      assert_equal 50, result
    end
  end
  
  context "IO" do
    context "Save" do
      setup do
        db_path = saved_db_path
        FileUtils.rm(db_path, :force => true)
        @a = DBMLP.new(db_path, :hidden_layers => [2], :output_nodes => 1, :inputs => 2)
      end
    
      should "create a file" do
        @a.save
        assert File.exists?(saved_db_path)
      end
    end
    
    context "Load" do
      setup do
        @db_path = saved_db_path
        FileUtils.rm(@db_path, :force => true)
        DBMLP.new(@db_path, :hidden_layers => [8], :output_nodes => 1, :inputs => 2).save
      end
    
      should "create a file" do
        a = DBMLP.load(@db_path)
        assert_equal 8, a.inspect[0].size
      end
    end
  end
   
  private
  
  def saved_db_path
    File.expand_path(File.dirname(__FILE__) + '/db/db.txt')
  end
  
  def set_data_variables
    @training = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
    @testing = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
    @validation = [[[0,0], [0]], [[0,1], [1]], [[1,0], [1]], [[1,1], [0]]]
  end

end
