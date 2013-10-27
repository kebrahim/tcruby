class Chef < ActiveRecord::Base
  attr_accessible :abbreviation, :first_name, :last_name

  has_and_belongs_to_many :users
  has_many :chefstats, dependent: :destroy
  has_many :stats, :through => :chefstats
  has_many :picks

  # Returns the full name of the chef
  def full_name
    return self.first_name + " " + self.last_name
  end

  # Returns a comma-separated list of users which own this chef
  def user_string(with_links = false)
    return self.users.collect { |user|
      with_links ? user.link_to_page_with_first_name : user.first_name
    }.join(", ")
  end

  # returns a link to this chef's page with the specified label
  def link_to_page_with_label(label)
    return ("<a href='chefs/" + self.id.to_s + "'>" + label + "</a>").html_safe
  end

  def link_to_page_with_first_name
    return link_to_page_with_label(self.first_name)
  end

  def link_to_page_with_full_name
    return link_to_page_with_label(self.full_name)
  end
end
