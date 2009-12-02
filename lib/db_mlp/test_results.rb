module TestResults
  
  private
  
  # Create a tab seperated file
  def create_test_report(test_examples, report_path)
    results = []
    results << "ID\tAttributes\tTarget\tResults\tError" # Add the headers
    
    test_examples.each_with_index do |example, index|
      input, target = example[0], example[1]
      feed_forward(input)
      info = "#{index}\t#{input.inspect}\t#{target.inspect}\t#{last_outputs.inspect}\t#{calculate_error(target)}"
      results << info
    end
    
    File.open(report_path, "w+") do |file|
      results.each do |line|
        file.write(line)
        file.write("\n")
      end
    end
  end
  
  # Calculates sum-of-squares error
  def calculate_error(targets)
    outputs = last_outputs
    sum = 0
    targets.each_with_index do |t, index|
      sum += (t - outputs[index]) ** 2
    end
    0.5 * sum
  end
  
end