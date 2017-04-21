Paperclip::Attachment.default_options.merge!(YAML.load(ERB.new(File.read("#{Rails.root}/config/paperclip.yml")).result)[Rails.env].symbolize_keys!)
