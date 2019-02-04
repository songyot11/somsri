describe "rake students:cleanup", type: :task do
  let(:students) do
    8.times.collect { Student.make! }
  end

  it "clean all prefix" do
    Student.where(id: students[0].id).update_all(full_name: "ด.ช. #{students[0].full_name}")
    Student.where(id: students[1].id).update_all(full_name: "ด.ญ. #{students[1].full_name}")
    Student.where(id: students[2].id).update_all(full_name: "Miss #{students[2].full_name}")
    Student.where(id: students[3].id).update_all(full_name: "miss #{students[3].full_name}")
    Student.where(id: students[4].id).update_all(full_name: "Master #{students[4].full_name}")
    Student.where(id: students[5].id).update_all(full_name: "master #{students[5].full_name}")
    Student.where(id: students[6].id).update_all(full_name: "เด็กชาย #{students[5].full_name}")
    Student.where(id: students[7].id).update_all(full_name: "เด็กหญิง #{students[5].full_name}")

    expect(Student.where("full_name LIKE 'ด.ช.%'").count).to eq 1
    expect(Student.where("full_name LIKE 'ด.ญ.%'").count).to eq 1
    expect(Student.where("full_name LIKE 'Miss%'").count).to eq 1
    expect(Student.where("full_name LIKE 'miss%'").count).to eq 1
    expect(Student.where("full_name LIKE 'Master%'").count).to eq 1
    expect(Student.where("full_name LIKE 'master%'").count).to eq 1
    expect(Student.where("full_name LIKE 'เด็กชาย%'").count).to eq 1
    expect(Student.where("full_name LIKE 'เด็กหญิง%'").count).to eq 1

    task.execute

    expect(Student.where("full_name LIKE 'ด.ช.%'").count).to eq 0
    expect(Student.where("full_name LIKE 'ด.ญ.%'").count).to eq 0
    expect(Student.where("full_name LIKE 'Miss%'").count).to eq 0
    expect(Student.where("full_name LIKE 'miss%'").count).to eq 0
    expect(Student.where("full_name LIKE 'Master%'").count).to eq 0
    expect(Student.where("full_name LIKE 'master%'").count).to eq 0
    expect(Student.where("full_name LIKE 'เด็กชาย%'").count).to eq 0
    expect(Student.where("full_name LIKE 'เด็กหญิง%'").count).to eq 0
  end
end
