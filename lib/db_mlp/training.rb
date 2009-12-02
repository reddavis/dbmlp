module Training
  
  private
  
  def train_and_cross_validate(training, validations, n)
    1.upto(n) do |i|
      if i % @validate_every == 0
        print_message("Validating at #{i}")
        
        if validates?(validations)
          print_message("Stopping at #{i}")
          break
        end
      end
      
      print_message("Iteration #{i}/#{n}")
      
      # Move the training data around a bit
      training = training.sort_by { rand }
      
      training.each do |t|
        input, target = t[0], t[1]
        training_process(input, target)
      end
    end #1.upto
  end
  
  # We are checking if the error has increased since we last checked
  # If it is we should probably stop training as we dont want to overfit the data
  def validates?(validations)
    validation = 0
    
    validations.each do |v|
      input, target = v[0], v[1]
      feed_forward(input)
      validation += calculate_error(target)
    end
    
    if @last_validation.nil? || (validation > @last_validation)
      false
    else
      true
    end
  end
  
  def training_process(input, targets)
    # To go back we must go forward
    feed_forward(input)
    compute_deltas(targets)
    update_weights(input)
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
    # If we have no hidden layer, just use the input, otherwise take
    # the outputs of the last hidden layer
    inputs = @hidden_layers.empty? ? input : @network[-2].map {|x| x.last_output}
    layer.each do |neuron|
      neuron.update_weight(inputs, 0.25)
    end
  end
  
  def update_hidden_weights(layer, layer_index, original_input)
    # If we're on the first hidden layer, we want to use the inputs from the input
    if layer_index == (@network.size - 1)
      inputs = original_input.clone
    # Or we want to use the inputs from the outputs of the previous layer
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
        compute_hidden_deltas(layer, targets, reversed_network[layer_index-1])
      end
    end
  end
  
  def compute_output_deltas(layer, targets)
    layer.each_with_index do |neuron, i|
      output = neuron.last_output
      neuron.delta = output * (1 - output) * (targets[i] - output)
    end
  end
  
  def compute_hidden_deltas(layer, targets, previous_layer)
    layer.each_with_index do |neuron, neuron_index|
      error = 0
      previous_layer.each do |previous_layer_neuron|
        error += previous_layer_neuron.delta * previous_layer_neuron.weights[neuron_index]
      end
      output = neuron.last_output
      neuron.delta = output * (1 - output) * error
    end
  end
  
end