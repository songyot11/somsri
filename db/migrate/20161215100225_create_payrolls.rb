class CreatePayrolls < ActiveRecord::Migration[5.0]
  def change
    create_table :payrolls do |t|
      t.belongs_to :employee, index: true
      #เงินได้
      t.decimal :salary, null: false, default: 0
      t.decimal :allowance, null: false, default: 0 #เบี้ยเลี้ยง
      t.decimal :attendance_bonus, null: false, default: 0 #เบี้ยขยัน
      t.decimal :ot, null: false, default: 0
      t.decimal :bonus, null: false, default: 0
      t.decimal :position_allowance, null: false, default: 0 #เงินค่าประจำตำแหน่ง
      t.decimal :extra_etc, null: false, default: 0
      #เงินหัก
      t.decimal :absence, null: false, default: 0
      t.decimal :late, null: false, default: 0
      t.decimal :tax, null: false, default: 0
      t.decimal :social_insurance, null: false, default: 0
      t.decimal :fee_etc, null: false, default: 0
      t.decimal :pvf, null: false, default: 0
      t.decimal :advance_payment, null: false, default: 0 #เงินผ่อนจ่ายค่าเบิกล่วงหน้า

      t.timestamps null: false
    end
  end
end
