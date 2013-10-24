namespace :importstat do

  # environment is a rake task that loads all models
  desc "Imports stat data from CSV file"
  task :stats => :environment do
    require 'csv'
    statcount = 0
    CSV.foreach(File.join(File.expand_path(::Rails.root), "/lib/assets/stats.csv")) do |row|
      name = row[0]
      points = row[1].to_i
      abbreviation = row[2]
      short_name = row[3]
      ordinal = row[4].to_i

      Stat.create(name: name, abbreviation: abbreviation, short_name: short_name, points: points,
      	          ordinal: ordinal)
      statcount += 1
    end
    puts "Imported " + statcount.to_s + " stats!"
  end

  desc "Imports scoring week data from CSV file"
  task :weeks => :environment do
    require 'csv'
    wkcount = 0
    year = Date.today.year
    CSV.foreach(File.join(File.expand_path(::Rails.root), "/lib/assets/weeks.csv")) do |row|
      # skip comment line
      if row[0].starts_with?("#")
        next
      end

      week_number = row[0].to_i
      game_date = row[1]
      game_time = row[2]

      # convert game date/time to datetime
      start_time = DateTime.strptime(game_date + " " + game_time + " Atlantic Time (Canada)",
          "%m/%d/%Y %H:%M:%S %Z")

      # create week entry
      week = Week.new
      week.number = week_number
      week.start_time = start_time
      if week.save
        wkcount += 1
      end
    end
    puts "Imported " + wkcount.to_s + " scoring weeks!"
  end

  desc "Imports stat type data from CSV file"
  task :types => :environment do
    require 'csv'
    typecount = 0
    CSV.foreach(File.join(File.expand_path(::Rails.root), "/lib/assets/stat_types.csv")) do |row|
      # skip comment line
      if row[0].starts_with?("#")
        next
      end

      stat_abbr = row[0]
      type_abbr = row[1]
      stat = Stat.find_by_abbreviation(stat_abbr)
      stat_type = Stat.type_abbreviation_to_type(type_abbr)
      
      if stat && stat_type
        stat.update_attribute(:stat_type, stat_type)
        typecount += 1
      end
    end
    puts "Imported " + typecount.to_s + " stat types!"
  end  
end
