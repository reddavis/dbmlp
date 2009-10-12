module Training
  
  private
  
  def train_and_cross_validate(training, validations, n)
    errors = []
    1.upto(n) do |i|
      if i % 200 == 0
        if validate(validations)
          print_message("Stopping at #{i}")
          break
        end
      end
      print_message("Iteration #{i}/#{n}")
      training = training.sort_by { rand } #shaken or stirred?
      training.each do |t|
        input, target = t[0], t[1]
        training_process(input, target)
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
  
end