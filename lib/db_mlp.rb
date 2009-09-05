require 'rubygems'
require 'datamapper'
require File.dirname(__FILE__) + '/models/neuron'

class DBMLP
    
  def initialize(db_path, options={})
    @input_size = options[:inputs]
    @hidden_layers = options[:hidden_layers]
    @number_of_output_nodes = options[:output_nodes]
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
  
  def train(training, testing, validations, n=3000)
    train_and_cross_validate(training, validations, n)
  end
  
  def inspect
    @network
  end
  
  private
  
  def train_and_cross_validate(training, validations, n)
    errors = []
    1.upto(n) do |i|
      if i % 200 == 0
        if validate(validations)
          puts "Stopping at #{i}"
          break
        end
      end
      training = training.sort_by { rand } #shaken or stirred?
      training.each do |t|
        input, target = t[0], t[1]
        training_process(input, target)
        #calculate_error(target) 
      end
    end
    save_all_neurons
  end
  
  def validate(validations)
    @validations ||= []
    sum = 0
    validations.each do |v|
      input, target = v[0], v[1]
      feed_forward(input)
      sum += calculate_error(target)
    end
    @validations << sum
    return false if @validations.size < 2
    #puts "#{@validations[-1]} #{@validations[-2]}"
    @validations[-1] > @validations[-2] ? true : false
  end
  
  def training_process(input, targets)
    # To go back we must go forward
    feed_forward(input)
    compute_deltas(targets)
    update_weights(input)
  end
  
  def save_all_neurons
    @network.each do |layer|
      layer.each {|n| n.save!}
    end
  end
  
  def update_weights(input)
    reversed_network = @network.reverse
    reversed_network.each_with_index do |layer, layer_index|
      if layer_index == 0
        update_output_weights(layer, layer_index, input)
      else
        update_hidden_weights(layer, layer_index, input)
      end
    end
  end
  
  def update_output_weights(layer, layer_index, input)
    inputs = @hidden_layers.empty? ? input : @network[-2].map {|x| x.last_output}
    layer.each do |neuron|
      neuron.update_weight(inputs, 0.25)
    end
  end
  
  def update_hidden_weights(layer, layer_index, original_input)
    if layer_index == (@network.size - 1)
      inputs = original_input.clone
    else
      inputs = @network.reverse[layer_index+1].map {|x| x.last_output}
    end
    layer.each do |neuron|
      neuron.update_weight(inputs, 0.25)
    end
  end
  
  def compute_deltas(targets)
    reversed_network = @network.reverse
    reversed_network.each_with_index do |layer, layer_index|
      if layer_index == 0
        compute_output_deltas(layer, targets)
      else
        compute_hidden_deltas(layer, targets)
      end
    end
  end
  
  def compute_output_deltas(layer, targets)
    layer.each_with_index do |neuron, i|
      output = neuron.last_output
      neuron.delta = output * (1 - output) * (targets[i] - output)
    end
  end
  
  def compute_hidden_deltas(layer, targets)
    layer.each_with_index do |neuron, neuron_index|
      error = 0
      @network.last.each do |output_neuron|
        error += output_neuron.delta * output_neuron.weights[neuron_index]
      end
      output = neuron.last_output
      neuron.delta = output * (1 - output) * error
    end
  end
  
  def calculate_error(targets)
    outputs = @network.last.map {|x| x.last_output}
    sum = 0
    targets.each_with_index do |t, index|
      sum += (t - outputs[index]) ** 2
    end
    0.5 * sum
  end
  
  def setup_network
    @network = []
    if new_mlp?
      wipe_db!      
      # Hidden Layers
      @hidden_layers.each_with_index do |number_of_neurons, index|
        layer = []
        inputs = index == 0 ? @input_size : @hidden_layers[index-1].size
        number_of_neurons.times { layer << Neuron.new(inputs, index) }
        @network << layer
        layer.each {|x| x.save!}
      end
      # Output layer
      inputs = @hidden_layers.empty? ? @input_size : @hidden_layers.last
      layer = []
      @number_of_output_nodes.times { layer << Neuron.new(inputs, -1)}
      @network << layer
      layer.each {|x| x.save!}
    else
      # Problematic area???
      @hidden_layers.each_index do |index|
        layer = Neuron.all(:layer_index => index, :order => [:id.asc])
        @network << layer
      end
      layer = Neuron.all(:layer_index => -1, :order => [:id.asc])
      @network << layer
    end
  end
  
  def wipe_db!
    DataMapper.auto_migrate!
  end
  
  # Only one mlp per DB, so if this mlp's shape is diff
  # to whats in the db then we empty and create a new one
  # if its the same then we carry on as we left off
  def new_mlp?
    new_mlp = false
    # Check hidden_layers
    @hidden_layers.each_index do |i|
      if Neuron.count(:layer_index => i) != @hidden_layers[i]
        new_mlp = true
      end
    end
    # Check output layer
    if Neuron.count(:layer_index => -1) != @number_of_output_nodes
      new_mlp = true
    end
    
    if Neuron.count != (@hidden_layers.size + 1)
      new_mlp = true
    end
    new_mlp
  end
  
  def connect_to_db(db_path)
#    DataMapper::Logger.new(STDOUT, :debug)
#    DataObjects::Sqlite3.logger = DataObjects::Logger.new(STDOUT, 0)
    DataMapper.setup(:default, db_path)
    DataMapper.auto_upgrade!
  end
  
end