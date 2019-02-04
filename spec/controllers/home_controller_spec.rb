describe HomeController do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:employees) do
    [
      Employee.make!({ school_id: school.id, pin: "1111" }),
      Employee.make!({ school_id: school.id, pin: "2222" })
    ]
  end

  it "should return user information" do
    get 'auth_api', params: { pin: employees[1]['pin'] }
    data = JSON.parse(response.body)
    expect(data['first_name']).to eq(employees[1].first_name);
  end

  it "should return error when using wrong PIN" do
    get 'auth_api', params: { pin: "00000" }
    data = JSON.parse(response.body)
    expect(data['errors']).to eq("Invalid PIN");
  end

end
