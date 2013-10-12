namespace :importchef do

  # environment is a rake task that loads all models
  desc "Imports chef data from CSV file"
  task :chefs => :environment do
    require 'csv'
    chefcount = 0
    CSV.foreach(File.join(File.expand_path(::Rails.root), "/lib/assets/chefs.csv")) do |row|
      first_name = row[0]
      last_name = row[1]
      abbreviation = row[2]
      
      Chef.create(first_name: first_name, last_name: last_name, abbreviation: abbreviation)

      chefcount += 1
    end
    puts "Imported " + chefcount.to_s + " chefs!"
  end

  desc "Imports draft data from CSV file"
  task :draft => :environment do
    require 'csv'
    draftcount = 0
    CSV.foreach(File.join(File.expand_path(::Rails.root), "/lib/assets/draft.csv")) do |row|
      league = row[0]
      round = row[1].to_i
      pick = row[2].to_i
      user_first_name = row[3]
      chef_abbr = row[4]
      
      # find user by first name
      user = User.find_by_first_name(user_first_name)

      # find chef by abbreviation
      chef = Chef.find_by_abbreviation(chef_abbr)

      if !user.nil? && !chef.nil?
        # create draft pick
        draft_pick = DraftPick.create(league: league, round: round, pick: pick)
        draft_pick.update_attribute(:user_id, user.id)
        draft_pick.update_attribute(:chef_id, chef.id)

        # assign chef to user
        user.chefs << chef

        draftcount += 1
      else
        puts "invalid user or chef: " + row
      end
    end
    puts "Imported " + draftcount.to_s + " draft picks!"
  end
end
