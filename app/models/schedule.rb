class Schedule < ApplicationRecord
  has_and_belongs_to_many :appointments
  has_and_belongs_to_many :users
end
