describe HomeController do
  let(:school) { school = School.make!({ name: "โรงเรียนแห่งหนึ่ง" }) }
  let(:users) do
    [
      User.make!({ school_id: school.id, pin: "1111" }),
      User.make!({ school_id: school.id, pin: "2222" })
    ]
  end

  it "should return user information" do
    get 'auth_api', params: { pin: users[1]['pin'] }
    data = JSON.parse(response.body)
    expect(data['name']).to eq(users[1].name);
  end

  it "should return error when using wrong PIN" do
    get 'auth_api', params: { pin: "00000" }
    data = JSON.parse(response.body)
    expect(data['errors']).to eq("Invalid PIN or user not registered");
  end

end
