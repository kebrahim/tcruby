module ChefsHelper

  def chef_users(chef)
    user_html = ""
    user_html << chef.users.collect { |user|
      user.first_name
    }.join(", ")
    return user_html.html_safe
  end

  def chef_picks(chef)
    picks_html = ""
    picks_html << @chef_id_to_picks_map[chef.id].collect { |pick|
      "Round: " + pick.round.to_s + ", Pick: " + pick.pick.to_s
    }.join(", ")
    return picks_html.html_safe
  end
end