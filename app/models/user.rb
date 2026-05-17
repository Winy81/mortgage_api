class User < ApplicationRecord

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
   
  has_many :mortgage_applications, dependent: :destroy       
end
