describe RollCallsController do

  let(:school)do
    School.make!
  end

  let(:users) do
    [
      User.make!(school_id: school.id),
      User.make!(school_id: school.id)
    ]
  end

  let(:students) do
    [
      Student.make!(school_id: school.id, student_number: 101, classroom_number: 1),
      Student.make!(school_id: school.id, student_number: 102, classroom_number: 2),
      Student.make!(school_id: school.id, student_number: 103, classroom_number: 3),
      Student.make!(school_id: school.id, student_number: 104, classroom_number: 1),
      Student.make!(school_id: school.id, student_number: 105, classroom_number: 2)
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
      StudentList.make!({ student_id: students[4].id, list_id: lists[1].id })
    ]
  end

  let(:datas) do
    {
      pin: users[0]['pin'],
      date_check_line: "2016-12-13",
      class: lists[0].name,
      morning: [{"student_code":"#{students[0].code}","status":"อัพเดต"}].to_json,
      afternoon: [{"student_code":"#{students[0].code}","status":"อัพเดต"}].to_json
    }
  end

  let(:datas_new) do
    {
      pin: users[0]['pin'],
      date_check_line: "2016-12-14",
      class: lists[0].name,
      morning: [{"student_code":"#{students[0].code}","status":"มา"}].to_json,
      afternoon: [{"student_code":"#{students[0].code}","status":"ไม่มา"}].to_json
    }
  end

  let(:roll_calls) do
    [
      RollCall.make!({ status: "มา", round: "morning", student_id: students[0].id, list_id: lists[0].id, check_date: "2016-12-13" }),
      RollCall.make!({ status: "ไม่มา", round: "afternoon", student_id: students[0].id, list_id: lists[0].id, check_date: "2016-12-13" }),
      RollCall.make!({ status: "มาสาย", round: "morning", student_id: students[1].id, list_id: lists[0].id, check_date: "2016-12-13" }),
      RollCall.make!({ status: "ลากิจ", round: "afternoon", student_id: students[2].id, list_id: lists[0].id, check_date: "2016-12-13" }),
      RollCall.make!({ status: "มาสาย", round: "morning", student_id: students[3].id, list_id: lists[1].id, check_date: "2016-12-13" }),
      RollCall.make!({ status: "ลากิจ", round: "afternoon", student_id: students[4].id, list_id: lists[1].id, check_date: "2016-12-13" })
    ]
  end

  before :each do
    users[0].add_role :admin
    students
    student_list
    roll_calls
  end

  describe "post: create /roll_calls" do
    it "should update roll_calls using ID_TOKEN" do
      post 'create', params: datas
      data = JSON.parse(response.body)
      expect(data.size).to eq(1)
      expect(data[0]["morning"].size).to eq(3)
      expect(data[0]["morning"][0]["first_name"]).to eq(students[0].first_name)
      expect(data[0]["morning"][0]["status"]).to eq("อัพเดต")
      expect(data[0]["afternoon"].size).to eq(3)
      expect(data[0]["afternoon"][0]["status"]).to eq("อัพเดต")
    end

    it "should create roll_calls using ID_TOKEN" do
      post 'create', params: datas_new
      data = JSON.parse(response.body)
      expect(data.size).to eq(1)
      expect(data[0]["date"]).to eq("2016-12-14")
      expect(data[0]["morning"].size).to eq(3)
      expect(data[0]["morning"][0]["status"]).to eq("มา")
      expect(data[0]["afternoon"].size).to eq(3)
      expect(data[0]["afternoon"][0]["status"]).to eq("ไม่มา")
    end
  end

  describe "get: index /roll_calls" do
    it "should return roll call with data" do
      get 'index', params: { pin: users[0]['pin'], date: "2016-12-13" }
      data = JSON.parse(response.body)
      expect(data.size).to eq(1)
      expect(data[0]["morning"].size).to eq(3)
      expect(data[0]["morning"][0]["status"]).to eq("มา")
      expect(data[0]["afternoon"].size).to eq(3)
      expect(data[0]["afternoon"][0]["status"]).to eq("ไม่มา")
    end

    it "should return blank roll call if there is no data" do
      get 'index', params: { pin: users[0]['pin'], date: "2016-12-14" }
      data = JSON.parse(response.body)
      expect(data.size).to eq(1)
      expect(data[0]["morning"].size).to eq(3)
      expect(data[0]["morning"][0]["status"]).to eq("")
      expect(data[0]["afternoon"].size).to eq(3)
      expect(data[0]["afternoon"][0]["status"]).to eq("")
    end

    it "should return roll call order by number" do
      get 'index', params: { pin: users[0]['pin'], date: "2016-12-13" }
      data = JSON.parse(response.body)
      expect(data.size).to eq(1)
      expect(data[0]["morning"].size).to eq(3)
      expect(data[0]["morning"][0]["number"]).to eq(1)
      expect(data[0]["morning"][1]["number"]).to eq(2)
      expect(data[0]["morning"][2]["number"]).to eq(3)
      expect(data[0]["afternoon"].size).to eq(3)
      expect(data[0]["afternoon"][0]["number"]).to eq(1)
      expect(data[0]["afternoon"][1]["number"]).to eq(2)
      expect(data[0]["afternoon"][2]["number"]).to eq(3)
    end
  end

end
