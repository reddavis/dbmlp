module TestResultsParser
  def self.included(base)
    base.extend(Parser)
  end
  
  module Parser
    
    def parse_test_results(filepath, error_limit=0.05)
      total, correct = 0.0, 0.0
      File.open(filepath) do |f|
        while line = f.gets do
          next if line.match(/ID/)
          error = line.match(/\t(\d+\..+)$/)[1]
          total += 1
          if error.to_f < error_limit
            correct += 1
          end
        end #while
      end #File.open
      
      correct / total * 100
    end
    
  end
end