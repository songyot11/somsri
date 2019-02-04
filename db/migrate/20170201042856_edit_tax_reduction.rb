class EditTaxReduction < ActiveRecord::Migration[5.0]
  def change
    rename_column :tax_reductions, :parent_alimony, :father_alimony
    add_column :tax_reductions, :mother_alimony, :decimal, default: 0, null: false
    rename_column :tax_reductions, :spouse_parent_alimony, :spouse_father_alimony
    add_column :tax_reductions, :spouse_mother_alimony, :decimal, default: 0, null: false
    rename_column :tax_reductions, :parent_insurance, :father_insurance
    add_column :tax_reductions, :mother_insurance, :decimal, default: 0, null: false
    add_column :tax_reductions, :spouse_father_insurance, :decimal, default: 0, null: false
    add_column :tax_reductions, :spouse_mother_insurance, :decimal, default: 0, null: false
    rename_column :tax_reductions, :education_donation, :double_donation
    rename_column :tax_reductions, :general_donation, :donation
  end
end
