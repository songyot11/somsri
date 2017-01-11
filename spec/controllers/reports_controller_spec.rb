describe ReportsController do
  it "should return santang" do
    ctrl = ReportsController.new
    expect(ctrl.send(:satang, 2000.00)).to eq("00")
    expect(ctrl.send(:satang, 20.01)).to eq("01")
    expect(ctrl.send(:satang, 2000.50)).to eq("50")
  end
end
