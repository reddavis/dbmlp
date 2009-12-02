require 'helper'

class TestNeuron < Test::Unit::TestCase  
  context "Initialization" do
    should "set initial weights" do
      a = create_neuron
      assert !a.weights.empty?
      assert_equal 4, a.weights.size  # + Bias node
    end
  end
  
  context "Weight Update" do
    should "change the weight of the neuron" do
      a = create_neuron
      before = a.weights.clone
      a.delta = 0.9
      a.update_weight([1,2,3], 0.5)
      assert_not_equal before, a.weights
    end
  end
  
  context "Fire" do
    should "change last_output" do
      a = create_neuron
      a.fire([1,2,3])
      assert a.last_output
    end
  end
  
  private
  
  def create_neuron(weights=3, layer_index=0)
    Neuron.new(weights, layer_index)
  end
end
