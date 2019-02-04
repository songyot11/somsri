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
  desc "Merge and soft delete duplicated students."
  task :clean_duplicated,  [] => :environment do |t, args|
    duplicateds = [[95,317],[158,378],[175,358,274],[327,336],[115,239,271],[373,272],[133,347],[309,370],[165.159],[250,216],[251,362],[371,267],[163,339,275],[85,255],[167,241,357],[166,356,242],[268,337,344],[180,218,355],[346,365,316],[192,206,219],[236,179],[249,310],[63,220],[189,203,238],[34,226],[188,204,243],[232,345,367,354],[170,262],[197,269],[137,208,263],[129,190],[313,312,323],[186,266,200,372],[195,252],[225,185],[342,325],[384,385],[210,244],[318,319],[1,331],[172,353,199,352],[326,333],[107,380],[363,364],[374,321],[177,349,361,228],[14,229],[173,202,308],[212,322,257],[162,217],[187,201,261],[230,350],[54,256,314],[174,369],[315,379],[135,222,247],[160,205],[209,214,368,366],[233,246],[234,335],[139,227]]
    duplicateds.each do |per_student|
      selected_id = per_student[0]
      per_student.shift
      per_student.each do |student_id|
        Invoice.where(student_id: student_id).update_all(student_id: selected_id)
        RollCall.where(student_id: student_id).update_all(student_id: selected_id)
        StudentList.where(student_id: student_id).update_all(student_id: selected_id)
        StudentsParent.where(student_id: student_id).update_all(student_id: selected_id)
        Student.where(id: student_id).first.destroy if Student.where(id: student_id).first
      end
    end
  end
end
