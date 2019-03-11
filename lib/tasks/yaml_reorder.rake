task :reorder_ccms_yaml do
  orig_hash = YAML.load_file(File.join(Rails.root, 'config', 'ccms', 'ccms_keys.yml'))
  reordered_keys =  YAML.load_file(File.join(Rails.root, 'config', 'ccms', 'reordered_keys.yml'))
  new_hash = {}

  reordered_keys.each do |section, keys|
    puts ">>>>>>>>>>>> SECTION #{section} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
    section_hash = {}
    keys.each do |key|
      puts "Key: #{key}"
      section_hash[key] = orig_hash[section][key]
    end
    new_hash[section] = section_hash
  end


  File.open(File.join(Rails.root, 'config', 'ccms', 'new_ccms_keys.yml'), 'w') do |fp|
    fp.puts new_hash.to_yaml
  end



end
