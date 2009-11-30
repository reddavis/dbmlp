class Neuron
  include DataMapper::Resource
  property :id, Serial
  property :layer_index, Integer, :index => true
  property :last_output, Float
  property :db_weights, String
  property :delta, Float
  
  def initialize(number_of_inputs, layer_index)
    create_weights(number_of_inputs)
    self.layer_index = layer_index
  end
  
  def fire(input)
    self.last_output = activation_function(input)
  end
  
  def update_weight(inputs, training_rate)
    inputs << -1  # Add the bias
    new_weights = weights
    weights.each_index do |i|
      new_weights[i] +=  training_rate * delta * inputs[i]
    end
    self.db_weights = new_weights.join(',')
  end
  
  def inspect
    weights
  end
  
  def weights
    db_weights.split(',').map {|x| x.to_f}
  end
  
  private
  
  def activation_function(input)
    sum = 0
    input.each_with_index do |n, index|
      sum +=  weights[index] * n
    end
    sum += weights.last * -1 #bias node
    sigmoid_function(sum)
  end
  
  # g(h) = 1 / (1+exp(-B*h(j)))
  def sigmoid_function(x)
    1 / (1+Math.exp(-1 * (x)))
  end
  
  def create_weights(number_of_inputs)
    # Create random weights between -1 & 1
    # Plus another one for the bias node
    weights = []
    (number_of_inputs + 1).times do
      weights << (rand > 0.5 ? -rand : rand)
    end
    self.db_weights = weights.join(',')
  end
  
end