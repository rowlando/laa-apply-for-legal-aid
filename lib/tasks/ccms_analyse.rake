namespace :ccms do
  task :analyse do
    require File.dirname(__FILE__) + '/../ccms_analysis/ccms_rule_analyser'
    CCMS::RuleAnalyser.new.run
  end
end
