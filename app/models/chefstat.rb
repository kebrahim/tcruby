class Chefstat < ActiveRecord::Base
  belongs_to :chef
  belongs_to :stat
  attr_accessible :week

  def my_identifier
    return Chefstat::identifier(self.chef_id, self.stat_id, self.week)
  end

  def self.identifier(chef_id, stat_id, week)
  	return chef_id.to_s + ":" + stat_id.to_s + ":" + week.to_s
  end
end
