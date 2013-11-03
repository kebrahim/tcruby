class DraftPick < ActiveRecord::Base
  extend Enumerize

  belongs_to :user
  belongs_to :chef
  attr_accessible :league, :pick, :round

  enumerize :league, in: [:poboy, :beignet]

  SORTABLE_COLUMNS = [:chef, :poboy, :beignet, :fantasy_points, :week].collect { |column|
  	  column.to_s
  }
end
