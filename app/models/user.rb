class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :school
  has_many :invoices, dependent: :destroy
  has_many :lists, dependent: :destroy
  has_many :class_permisions, dependent: :destroy

  def admin?
    true
  end

  include Gravtastic
  gravtastic
end
