# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{db_mlp}
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["reddavis"]
  s.date = %q{2009-11-11}
  s.description = %q{Database backed Multi-Layer Perceptron Neural Network in Ruby}
  s.email = %q{reddavis@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".autotest",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "benchmarks/data.rdb",
     "benchmarks/mlp_benchmark.rb",
     "db_mlp.gemspec",
     "examples/backpropagation_example.rb",
     "examples/data.rdb",
     "examples/patterns_with_base_noise.rb",
     "examples/patterns_with_noise.rb",
     "examples/training_patterns.rb",
     "examples/xor.rb",
     "lib/db_mlp.rb",
     "lib/models/neuron.rb",
     "lib/modules/create_test_results.rb",
     "lib/modules/db.rb",
     "lib/modules/test_results_parser.rb",
     "lib/modules/training.rb",
     "profiling/profile.rb",
     "test/db/test.txt",
     "test/db/test_results_test/results.txt",
     "test/helper.rb",
     "test/test_db_mlp.rb"
  ]
  s.homepage = %q{http://github.com/reddavis/dbmlp}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Database backed Multi-Layer Perceptron Neural Network in Ruby}
  s.test_files = [
    "test/helper.rb",
     "test/test_db_mlp.rb",
     "examples/backpropagation_example.rb",
     "examples/patterns_with_base_noise.rb",
     "examples/patterns_with_noise.rb",
     "examples/training_patterns.rb",
     "examples/xor.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

