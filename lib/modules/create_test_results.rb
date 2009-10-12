module CreateTestResults
  
  private
  
  def create_test_report(test_examples, report_path)
    results = []
    
    test_examples.each_with_index do |example, index|
      input, target = example[0], example[1]
      feed_forward(input)
      info = "ID: #{index}\tAttributes: #{input.inspect}\tTarget: #{target}\tResuts: #{last_outputs}\tError: #{calculate_error(target)}\t"
      results << info
    end
    
    File.open(report_path, "w+") do |file|
      results.each do |line|
        file.write(line)
        file.write("\n")
      end
    end
  end
  
  def calculate_error(targets)
    outputs = last_outputs
    sum = 0
    targets.each_with_index do |t, index|
      sum += (t - outputs[index]) ** 2
    end
    0.5 * sum
  end
  
end