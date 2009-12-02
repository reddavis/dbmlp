require File.expand_path(File.dirname(__FILE__) + '/db_mlp/neuron')
require File.expand_path(File.dirname(__FILE__) + '/db_mlp/test_results')
require File.expand_path(File.dirname(__FILE__) + '/db_mlp/training')
require File.expand_path(File.dirname(__FILE__) + '/db_mlp/test_results_parser')
require File.expand_path(File.dirname(__FILE__) + '/db_mlp/network')

class DBMLP
  include Network
  include Training
  include TestResults
  include TestResultsParser
  
  class << self
    def load(db_path)
      data = ""
      File.open(db_path) do |f|
        while line = f.gets
          data << line
        end
      end
      Marshal.load(data)
    end
  end
  
  def initialize(db_path, options={})
    @input_size = options[:inputs]
    @hidden_layers = options[:hidden_layers]
    @output_nodes = options[:output_nodes]
    @verbose = options[:verbose]
    @validate_every = options[:validate_every] || 200
    @db_path = db_path
        
    @network = setup_network
  end
  
  def feed_forward(input)
    @network.each_with_index do |layer, layer_index|
      # We go through each layer taking the previous layers outputs and using them
      # as the next layers inputs
      layer.each do |neuron|
        if layer_index == 0
          neuron.fire(input)
        else
          input = @network[layer_index-1].map {|x| x.last_output}
          neuron.fire(input)
        end
      end
    end
    last_outputs
  end
  
  def train(training, testing, validations, n=3000, report_path=nil)
    train_and_cross_validate(training, validations, n)
    # Create a test report if they want one
    create_test_report(testing, report_path) unless report_path.nil?
    save
  end
  
  def inspect
    @network
  end
  
  def save
    File.open(@db_path, 'w+') do |f|
      f.write(Marshal.dump(self))
    end
  end
      
  private
  
  def last_outputs
    @network.last.map {|x| x.last_output}
  end
  
  def print_message(message)
    puts message if @verbose
  end
  
end