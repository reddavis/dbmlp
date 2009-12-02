class Neuron
  
  attr_accessor :delta
  
  attr_reader :layer_index, :last_output
  
  def initialize(number_of_inputs, layer_index)
    create_weights(number_of_inputs)
    @layer_index = layer_index
  end
  
  def fire(input)
    @last_output = activation_function(input)
  end
  
  def update_weight(inputs, training_rate)
    inputs << -1  # Add the bias node
        
    weights.each_index do |i|
      weights[i] +=  training_rate * delta * inputs[i]
    end
  end
  
  def inspect
    weights
  end
  
  def weights
    @weights ||= []
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
    (number_of_inputs + 1).times do
      weights << (rand > 0.5 ? -rand : rand)
    end
  end
  
end