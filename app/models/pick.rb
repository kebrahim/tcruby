class Pick < ActiveRecord::Base
  extend Enumerize

  belongs_to :user
  belongs_to :chef
  attr_accessible :number, :points, :record, :week

  enumerize :record, in: [:win, :loss]
end
