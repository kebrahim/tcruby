class Pick < ActiveRecord::Base
  extend Enumerize

  belongs_to :user
  belongs_to :chef
  attr_accessible :number, :points, :record, :week

  enumerize :record, in: [:win, :loss]

  MISMATCH_PENALTY = -1
  MAX_BONUS = 5
  WEEKLY_STEP = 3

  def self.abbreviation_to_record(record_abbreviation)
    if record_abbreviation == "W"
      return :win
    elsif record_abbreviation == "L"
      return :loss
    end
    return nil
  end

  def my_record_abbreviation
    return Pick::record_abbreviation(self.record)
  end
  
  def self.record_abbreviation(record)
    if record == :win || record == :win.to_s
      return "W"
    elsif record == :loss || record == :loss.to_s
      return "L"
    end
    return nil
  end

  def my_record_string
    return Pick::record_string(self.record)
  end

  def self.record_string(record)
    if record == :win || record == :win.to_s
      return "Win"
    elsif record == :loss || record == :loss.to_s
      return "Loss"
    end
    return nil
  end

  # returns the record associated with the specified record string
  def self.record_type_from_string(record_string)
    [:win, :loss].each { |record|
      if record.to_s == record_string
        return record
      end
    }
    return nil
  end

  def my_user_week_record_id
    return Pick::user_week_record_id(self.user_id, self.week, self.record)
  end

  def self.user_week_record_id(user_id, week, record)
    return user_id.to_s + ":" + week.to_s + ":" + record.to_s
  end
end
