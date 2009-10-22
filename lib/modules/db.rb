module DB
  
  private
  
  def setup_network
    @network = []
    if new_mlp?
      wipe_db!      
      # Hidden Layers
      @hidden_layers.each_with_index do |number_of_neurons, index|
        layer = []
        inputs = index == 0 ? @input_size : @hidden_layers[index-1]#.size
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