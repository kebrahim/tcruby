class Chefstat < ActiveRecord::Base
  belongs_to :chef
  belongs_to :stat
  attr_accessible :week
end
