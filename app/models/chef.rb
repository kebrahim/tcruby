class Chef < ActiveRecord::Base
  attr_accessible :abbreviation, :first_name, :last_name

  has_and_belongs_to_many :users
  has_many :chefstats, dependent: :destroy
  has_many :stats, :through => :chefstats
  has_many :picks

  # Returns the full name of the chef
  def full_name
    return self.first_name + " " + self.last_name
  end
end
