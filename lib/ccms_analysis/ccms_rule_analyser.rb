require 'CSV'

module CCMS
  class RuleAnalyser

    BR100_KEYS = (File.dirname(__FILE__) + '/BR100_keys.csv').freeze
    CCMS_RULES = (File.dirname(__FILE__) + '/ccms_rules.csv').freeze
    NEW_BR100_KEYS = (File.dirname(__FILE__) + '/BR100_new_keys.csv').freeze

    def initialize
      @br100_keys = CSV.read BR100_KEYS
      @ccms_rules = CSV.read CCMS_RULES
      @ccms_rules.shift # remove header row
      @br100_keys.shift # remove header row
      @new_keys = []
      @new_keys << %w[KEY MEANING DESCRIPTION Sheet CCMS-rule]
    end

    def run
      @br100_keys.each_with_index do |key_row, i|
        ccms_rules = rules_for(key_row, i)
        @new_keys << key_row + [ccms_rules]
      end
      write_new_keys
    end

    private

    def rules_for(key_row, row_num)
      rule_names = []
      key = key_row.first
      puts ">>>>>>>>>>    #{row_num}:#{key}     #{__FILE__}:#{__LINE__} <<<<<<<<<<"
      @ccms_rules.each do |ccms_rule_row|
        _rule_start, rule_name, query, start_row, _length = ccms_rule_row
        if query =~/#{key}/i
          rule_names << "#{rule_name}-#{start_row}"
        end
      end
      rule_names.join(",")
    end

    def write_new_keys
      CSV.open(NEW_BR100_KEYS, "wb") do |csv|
        @new_keys.each do |new_key_row|
          csv << new_key_row
        end
      end
    end
  end
end
