class DraftPick < ActiveRecord::Base
  extend Enumerize

  belongs_to :user
  belongs_to :chef
  attr_accessible :league, :pick, :round

  enumerize :league, in: [:poboy, :beignet]
end
