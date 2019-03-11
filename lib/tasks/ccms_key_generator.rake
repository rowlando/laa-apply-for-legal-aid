###############################################
#                                             #
# remove this file before merging with master #
#                                             #
###############################################

namespace :ccms do

  desc 'Generate yaml file from ccms_keys.csv'
  task generate_yaml: :environment do
    require 'csv'

    INFILE = File.join(Rails.root, 'config', 'ccms', 'ccms_keys.csv')
    OFILE = File.join(Rails.root, 'config', 'ccms', 'ccms_keys.yml')
    result = {}
    current_section = nil


    CSV.foreach(INFILE) do |row|
      next if row == ["section",
                      "attribute",
                      "value",
                      "meaning in BR100",
                      "Response Type",
                      "User defined"]
      section, key, value, meaning, response_type, user_defined = row
      if current_section != section
        result[section] = {}
        current_section = section
      end
      if response_type == 'boolean'
        value = value.upcase == 'TRUE' ? true : false
      end
      user_defined = user_defined == 'TRUE' ? true : false
      meaning = meaning == '#N/A' ? 'Meaning not defined in BR100' : meaning

      result[section][key] = {value: value, br100_meaning: meaning, response_type: response_type, user_defined: user_defined}
    end

    File.open(OFILE, 'w') do |fp|
      fp.puts result.to_yaml
    end


  end
end
