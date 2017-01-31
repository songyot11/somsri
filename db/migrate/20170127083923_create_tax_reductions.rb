class CreateTaxReductions < ActiveRecord::Migration[5.0]
  def change
    create_table :tax_reductions do |t|
      t.belongs_to :employee, index: true
      t.decimal :pension_insurance, null: false, default: 0 #เบี้ยประกันชีวิตแบบบำนาญ
      t.decimal :pension_fund, null: false, default: 0 #กองทุนสำรองเลี้ยงชีพ
      t.decimal :government_pension_fund, null: false, default: 0 #เงินสะสม กบข
      t.decimal :private_teacher_aid_fund, null: false, default: 0 #เงินสะสมกองทุนสงเคราะห์ครูโรงเรียนเอกชน
      t.decimal :retirement_mutual_fund, null: false, default: 0 #ค่าซื้อหน่วยลงทุนในกองทุนรวมเพื่อการเลี้ยงชีพ RMF
      t.decimal :national_savings_fund, null: false, default: 0 #เงินสะสมกองทุนการออมแห่งชาติ
      t.decimal :expenses, null: false, default: 0 # ค่าใช้จ่าย
      t.decimal :no_income_spouse, null: false, default: 0 # ลดหย่อนสำหรับคู่สมรสที่ไม่มีรายได้
      t.decimal :child, null: false, default: 0 # ลดหย่อนบุตร
      t.decimal :parent_alimony, null: false, default: 0 # อุปการะเลี้ยงดูบิดามารดาที่มีอายุตั้งแต่ 60 ปีขึ้นไป
      t.decimal :spouse_parent_alimony, null: false, default: 0 # อุปการะเลี้ยงดูบิดามารดาของคู่สมรส
      t.decimal :cripple_alimony, null: false, default: 0 # อุปการะเลี้ยงดูคนพิการ และหรือคนทุพพลภาพ
      t.decimal :parent_insurance, null: false, default: 0 # เบี้ยประกันสุขภาพบิดามารดาของผู้มีเงินได้และคู่สมรส
      t.decimal :insurance, null: false, default: 0 # เบี้ยประกันชีวิต
      t.decimal :spouse_insurance, null: false, default: 0 # เบี้ยประกันชีวิตของคู่สมรสที่ไม่มีรายได้
      t.decimal :long_term_equity_fund, null: false, default: 0 # ค่าซื้อหน่วยลงทุนในกองทุนรวมหุ้นระยะยาว LTF
      t.decimal :social_insurance, null: false, default: 0 # เงินสมทบกองทุนประกันสังคม
      t.decimal :education_donation, null: false, default: 0 # เงินบริจาคสนับสนุนการศึกษา
      t.decimal :general_donation, null: false, default: 0 # เงินบริจาคอื่นๆ
      t.decimal :other, null: false, default: 0 # ค่าลดหย่อนอื่นๆ
    end
  end
end
