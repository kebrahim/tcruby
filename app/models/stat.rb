class Stat < ActiveRecord::Base
  attr_accessible :abbreviation, :name, :ordinal, :points, :short_name
end
