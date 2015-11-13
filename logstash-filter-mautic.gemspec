Gem::Specification.new do |s|
  s.name = 'logstash-filter-mautic'
  s.version         = '0.1'
  s.licenses = ['Apache License (2.0)']
  s.summary = "Receives Mautic webhook data to view in Elasticsearch"
  s.description = "This plugin lets you get the majority of you Mautic data into Elasticsearch for viewing using Kibana. Just setup a http input for logstash and a filter like so mautic { source => 'message'}. See the GitHub repository for more information"
  s.authors = ["Zac Petterd"]
  s.email = 'zac@sproutlabs.com.au'
  s.homepage = "https://github.com/zapur1/logstash-filter-mautic"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 2.0.0", "< 3.0.0"
  s.add_development_dependency 'logstash-devutils'
end
