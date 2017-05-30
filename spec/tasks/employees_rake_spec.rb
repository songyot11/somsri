describe "rake employees:pin:generate", type: :task do
  let(:employees) do
    100.times.collect { Employee.make!(pin: nil) }
  end

  before :each do
    employees
  end

  it "clean all prefix" do
    Employee.where("pin IS NOT NULL").update_all(pin: nil)
    employees.last.update(pin: '1111')
    expect(Employee.where("pin IS NOT NULL").count).to eq 1
    expect{ task.execute }.to change{ Employee.where("pin IS NOT NULL").count }.by 99
    all_employees_pin = Employee.all.collect(&:pin)
    duplicated_pins = all_employees_pin.group_by{ |e| e }.select { |k, v| v.size > 1 }.map(&:first)
    expect(duplicated_pins.length).to eq(0)
  end
end
