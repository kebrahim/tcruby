class Chef < ActiveRecord::Base
  attr_accessible :abbreviation, :first_name, :last_name

  has_and_belongs_to_many :users

  # Returns the full name of the chef
  def full_name
    return self.first_name + " " + self.last_name
  end
end
