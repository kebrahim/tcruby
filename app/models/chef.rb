class Chef < ActiveRecord::Base
  attr_accessible :abbreviation, :first_name, :last_name

  # Returns the full name of the chef
  def full_name
    return self.first_name + " " + self.last_name
  end
end
