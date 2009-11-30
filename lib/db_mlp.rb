require 'datamapper'
require File.expand_path(File.dirname(__FILE__) + '/models/neuron')
require File.expand_path(File.dirname(__FILE__) + '/modules/create_test_results')
require File.expand_path(File.dirname(__FILE__) + '/modules/db')
require File.expand_path(File.dirname(__FILE__) + '/modules/training')
require File.expand_path(File.dirname(__FILE__) + '/modules/test_results_parser')

class DBMLP
  include DB
  include Training
  include CreateTestResults
  include TestResultsParser
    
  def initialize(db_path, options={})
    @input_size = options[:inputs]
    @hidden_layers = options[:hidden_layers]
    @number_of_output_nodes = options[:output_nodes]
    @verbose = options[:verbose]
    @validate_every = options[:validate_every] || 200
    
    connect_to_db(db_path)
    setup_network
  end
  
  def feed_forward(input)
    @network.each_with_index do |layer, layer_index|
      layer.each do |neuron|
        if layer_index == 0
          neuron.fire(input)
        else
          input = @network[layer_index-1].map {|x| x.last_output}
          neuron.fire(input)
        end
      end
    end
    @network.last.map {|x| x.last_output}
  end
  
  def train(training, testing, validations, n=3000, report_path=nil)
    train_and_cross_validate(training, validations, n)
    create_test_report(testing, report_path) unless report_path.nil?
  end
  
  def inspect
    @network
  end
  
  private
  
  def last_outputs
    @network.last.map {|x| x.last_output}
  end
  
  def print_message(message)
    puts message if @verbose
  end
  
end