namespace :importpick do

  # environment is a rake task that loads all models
  desc "Imports stat data from CSV file"
  task :picks => :environment do
    require 'csv'
    pickcount = 0
    CSV.foreach(File.join(File.expand_path(::Rails.root), "/lib/assets/picks.csv")) do |row|
      # skip comment line
      if row[0].starts_with?("#")
        next
      end

      week = row[0].to_i
      number = row[1].to_i
      user_first_name = row[2]
      chef_abbr = row[3]
      record = row[4]

      # find user by first name
      user = User.find_by_first_name(user_first_name)

      # find chef by abbreviation
      chef = Chef.find_by_abbreviation(chef_abbr)

      if !user.nil? && !chef.nil?
        # create pick
        pick = Pick.new
        pick.week = week
        pick.chef_id = chef.id
        pick.user_id = user.id
        pick.number = number
        pick.record = Pick::abbreviation_to_record(record)
        pick.points = 0

        pick.save
        pickcount += 1
      else
        puts "invalid user or chef: " + row
      end
    end
    puts "Imported " + pickcount.to_s + " picks!"
  end
end
