class TaxReduction < ApplicationRecord
  belongs_to :employee
  before_save :before_save

  def self.income_exemption(year_income, t) # รายได้ที่ได้รับการยกเว้น
    t = JSON.parse(t)
    p_insurance = t["pension_insurance"].to_i > year_income * 0.15 ? year_income * 0.15 : t["pension_insurance"].to_i
    p_insurance = p_insurance > 200000 ? 200000 : p_insurance
    g_fund = t["government_pension_fund"].to_i > 500000 ? 500000 : t["government_pension_fund"].to_i
    t_fund = t["private_teacher_aid_fund"].to_i > 500000 ? 500000 : t["private_teacher_aid_fund"].to_i
    r_fund = t["retirement_mutual_fund"].to_i > year_income * 0.15 ? year_income * 0.15 : t["retirement_mutual_fund"].to_i
    r_fund = 500000 if r_fund > 500000
    n_fund = t["national_savings_fund"].to_i > 13200 ? 13200 : t["national_savings_fund"].to_i
    ins = t["insurance"].to_i > 10000 ? t["insurance"].to_i : 0
    ins = ins > 90000 ? 90000 : ins
    p_fund = t["pension_fund"].to_i > year_income * 0.15 ? year_income * 0.15 : t["pension_fund"].to_i
    p_fund = p_fund > 200000 ? 200000 : p_fund
    exempt = p_insurance + p_fund + g_fund + t_fund + r_fund + n_fund + ins
    max_exempt_income = 500000

    exempt > max_exempt_income ? max_exempt_income : exempt
  end

  def self.revenue_reduction(income, t) # ค่าลดหย่อนภาษีเงินได้
    t = JSON.parse(t)
    exp40 = income*0.4 > 60000 ? 60000 : income*0.4;
    ltf = t["long_term_equity_fund"].to_i > income * 0.15 ? income * 0.15 : t["long_term_equity_fund"].to_i
    house_loan = t["house_loan_interest"].to_i > 100000 ? 100000 : t["house_loan_interest"].to_i
    d_donation = t["double_donation"].to_i * 2 > income * 0.1 ? income * 0.1 : t["double_donation"].to_i * 2
    s_donation = t["donation"].to_i > income * 0.1 ? income * 0.1 : t["donation"].to_i
    ins = t["insurance"].to_i > 10000 ? 10000 : t["insurance"].to_i
    p_ins = t["father_insurance"].to_i + t["mother_insurance"].to_i + t["spouse_father_insurance"].to_i + t["spouse_mother_insurance"].to_i
    p_ins = p_ins > 15000 ? 15000 : p_ins
    s_ins = t["spouse_insurance"].to_i > 100000 ? 100000 : t["spouse_insurance"].to_i

    exp40 + t["expenses"].to_i + t["no_income_spouse"].to_i + t["child"].to_i + t["father_alimony"].to_i + t["mother_alimony"].to_i + t["spouse_father_alimony"].to_i + t["spouse_mother_alimony"].to_i + t["cripple_alimony"].to_i + p_ins + ins + ltf + house_loan + s_ins + t["social_insurance"].to_i + d_donation + s_donation + t["other"].to_i
  end
  
  def before_save
    self.attributes.each_pair { |name, value| self[name] = "0.0" if value.nil? }
  end
end