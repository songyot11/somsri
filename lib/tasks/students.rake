namespace :students do
  desc "Remove all prefix(Master, Miss, ด.ช., ด.ญ.)"
  task :cleanup,  [] => :environment do |t, args|
    Student.all.each do |student|
      has_prefix = student.full_name =~ /^master/i ||
        student.full_name =~ /^miss/i ||
        student.full_name =~ /^ด\.ช\./ ||
        student.full_name =~ /^ด\.ญ\./ ||
        student.full_name =~ /^เด็กชาย/ ||
        student.full_name =~ /^เด็กหญิง/

      if has_prefix
        puts "Cleanup #{student.full_name}" unless Rails.env.test?
        student.full_name.gsub!(/^master/i, '')
        student.full_name.gsub!(/^miss/i, '')
        student.full_name.gsub!(/^ด\.ช\./, '')
        student.full_name.gsub!(/^ด\.ญ\./, '')
        student.full_name.gsub!(/^เด็กชาย/, '')
        student.full_name.gsub!(/^เด็กหญิง/, '')
        student.full_name.strip!
        student.save
      end
    end
  end
end
