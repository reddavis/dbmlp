module Network
  private
  
  # Creates a network from left to right (output nodes on the right)
  def setup_network
    hidden_layers << output_layer
  end
  
  def hidden_layers
    network = []
    @hidden_layers.each_with_index do |neurons, index|
      # Number of inputs
      if index == 0
        inputs = @input_size
      else
        inputs = network.last.size
      end
      
      layer = []
      neurons.times { layer << Neuron.new(inputs, index) }
      network << layer
    end
    network
  end
  
  def output_layer
    nodes = []
    inputs = @hidden_layers.last
    @output_nodes.times {|n| nodes << Neuron.new(inputs, n) }
    nodes
  end
end