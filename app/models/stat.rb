class Stat < ActiveRecord::Base
  attr_accessible :abbreviation, :name, :ordinal, :points, :short_name

  has_many :chefstats, dependent: :destroy
  has_many :chefs, :through => :chefstats
end
