describe StudentsController do

  let(:schools)do
    [
      School.make!,
      School.make!
    ]
  end

  let(:users) do
    [
      User.make!(school_id: schools[0].id),
      User.make!(school_id: schools[1].id)
    ]
  end

  let(:students) do
    [
      Student.make!(school_id: schools[0].id, student_number: 101, classroom_number: 1),
      Student.make!(school_id: schools[0].id, student_number: 102, classroom_number: 2),
      Student.make!(school_id: schools[0].id, student_number: 103, classroom_number: 3),
      Student.make!(school_id: schools[1].id, student_number: 104, classroom_number: 1),
      Student.make!(school_id: schools[1].id, student_number: 105, classroom_number: 2)
    ]
  end

  let(:lists) do
    [
      List.make!({ name: "ม. 1/1", category: "roll_call", user_id: users[0].id }),
      List.make!({ name: "ม. 1/2", category: "roll_call", user_id: users[1].id })
    ]
  end

  let(:student_list) do
    [
      StudentList.make!({ student_id: students[0].id, list_id: lists[0].id }),
      StudentList.make!({ student_id: students[1].id, list_id: lists[0].id }),
      StudentList.make!({ student_id: students[2].id, list_id: lists[0].id }),
      StudentList.make!({ student_id: students[3].id, list_id: lists[1].id }),
      StudentList.make!({ student_id: students[4].id, list_id: lists[1].id }),
    ]
  end

  before :each do
    users[0].add_role :admin
    students
  end

  describe "get: index /students" do
    it "should return student in user's school using PIN" do
      get 'index', params: { pin: users[0]['pin'] }
      data = JSON.parse(response.body)
      expect(data.size).to eq(3)
      found_data = 0
      data.each do |d|
        students.each do |s|
          if d["code"] == s.code
            found_data += 1
          end
        end
      end
      expect(found_data).to eq(3)
    end
  end


  describe "get: show /students/:id" do
    it "should return a student using PIN" do
      get 'show', params: { id: students[1].student_number, pin: users[0]['pin'] }
      data = JSON.parse(response.body)
      expect(data.size).to eq(1)
      expect(data[0]["code"]).to eq(students[1].code)
    end
  end


  describe "get: get_roll_calls /get_roll_calls/" do
    it "should return student in user's roll call using PIN" do
      student_list
      get 'get_roll_calls', params: { pin: users[0]['pin'] }
      data = JSON.parse(response.body)
      expect(data.size).to eq(3)
      found_data = 0
      data.each do |d|
        students.each do |s|
          if d["code"] == s.code
            found_data += 1
          end
        end
      end
      expect(found_data).to eq(3)
    end
  end


end
