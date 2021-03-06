class Stat < ActiveRecord::Base
  extend Enumerize

  attr_accessible :abbreviation, :name, :ordinal, :points, :short_name, :stat_type, :report_name

  enumerize :stat_type, in: [:quickfire, :elimination, :miscellaneous]

  has_many :chefstats, dependent: :destroy
  has_many :chefs, :through => :chefstats

  WINNER_ABBR = "W"
  TEAM_WINNER_ABBR = "Wt"
  ELIMINATED_ABBR = "E"
  QUICKFIRE_WINNER_ABBR = "Qi"
  QUICKFIRE_TEAM_WINNER_ABBR = "Qt"

  ALL_TYPES_ARRAY = [:quickfire, :elimination, :miscellaneous]

  def self.type_abbreviation_to_type(type_abbreviation)
    if type_abbreviation == "Q"
      return :quickfire
    elsif type_abbreviation == "E"
      return :elimination
    elsif type_abbreviation == "M"
      return :miscellaneous
    end
    return nil
  end

  def my_stat_type
    return Stat::get_stat_type(self.stat_type)
  end

  def self.get_stat_type(stat_type)
    if stat_type.to_s == :quickfire.to_s
      return :quickfire
    elsif stat_type.to_s == :elimination.to_s
      return :elimination
    elsif stat_type.to_s == :miscellaneous.to_s
      return :miscellaneous
    end
    return nil
  end
end
