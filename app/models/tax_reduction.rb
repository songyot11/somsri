class TaxReduction < ApplicationRecord
  belongs_to :employee

  def income_exemption # รายได้ที่ได้รับการยกเว้น
    year_income = self.employee.year_income
    p_insurance = pension_insurance > year_income * 0.15 ? year_income * 0.15 : pension_insurance
    p_insurance = p_insurance > 100000 ? 100000 : p_insurance
    p_fund = pension_fund > year_income * 0.15 ? year_income * 0.15 : pension_fund
    p_fund = p_fund > 200000 ? 200000 : p_fund
    # p_fund -= 10000 if p_fund >= 10000
    g_fund = government_pension_fund > 500000 ? 500000 : government_pension_fund
    t_fund = private_teacher_aid_fund > 500000 ? 500000 : private_teacher_aid_fund
    r_fund = retirement_mutual_fund > year_income * 0.15 ? year_income * 0.15 : retirement_mutual_fund
    r_fund = r_fund > 500000 ? 500000 : r_fund
    n_fund = national_savings_fund > year_income * 0.15 ? year_income * 0.15 : national_savings_fund
    n_fund = n_fund > 500000 ? 500000 : n_fund

    exempt = p_insurance + p_fund + g_fund + t_fund + r_fund + n_fund
    max_exempt_income = 500000
    exempt > max_exempt_income ? max_exempt_income : exempt
  end

  def revenue_reduction # ค่าลดหย่อนภาษีเงินได้
    income = self.employee.year_income - self.income_exemption
    exp40 = income*0.4 > 60000 ? 60000 : income*0.4
    ltf = long_term_equity_fund > income * 0.15 ? income * 0.15 : long_term_equity_fund
    house_loan = house_loan_interest >= 100000 ? 100000 : house_loan_interest
    d_donation = double_donation * 2 > income * 0.1 ? income * 0.1 : double_donation * 2
    s_donation = donation > income * 0.1 ? income * 0.1 : donation
    ins = insurance >= 100000 ? 100000 : insurance

    reduction = exp40 + expenses + no_income_spouse + child + father_alimony + mother_alimony + spouse_father_alimony + spouse_mother_alimony + cripple_alimony + father_insurance + mother_insurance + spouse_father_insurance + spouse_mother_insurance + ins + spouse_insurance + ltf + house_loan + social_insurance + d_donation + s_donation + other
  end
end
