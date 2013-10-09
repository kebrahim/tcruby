# Navigation bar helper
module NavigationHelper
  DASHBOARD_BUTTON = "DASHBOARD_BUTTON"
  SCOREBOARD_BUTTON = "SCOREBOARD_BUTTON"
  MY_TEAM_BUTTON = "MY_TEAM_BUTTON"
  WEEKLY_PICKS_BUTTON = "WEEKLY_PICKS_BUTTON"

  # Admin buttons
  ADMIN_USERS_BUTTON = "ADMIN_USERS_BUTTON"
  ADMIN_SCORING_WEEKS_BUTTON = "ADMIN_SCORING_WEEKS_BUTTON"

  # User buttons
  EDIT_PROFILE_BUTTON = "EDIT_PROFILE_BUTTON"

  def navigationBar(selected_button)
    navbar = "<div class='navbar'><div class='navbar-inner'>"
    if current_user
      navbar <<
        "<div class='brand'>Top Chef Rotiss</div>
         <ul class='nav'>" <<
         vertical_divider <<
         button_link(DASHBOARD_BUTTON, "Dashboard", "/dashboard", selected_button) <<
         button_link(SCOREBOARD_BUTTON, "Scoreboard", "/scoreboard", selected_button) <<
         button_link(MY_TEAM_BUTTON, "My Team", "/my_team", selected_button) <<
         button_link(WEEKLY_PICKS_BUTTON, "Weekly Picks", "/picks", selected_button)

      # only show Admin dropdown for admin users
      if current_user.is_admin
        admin_buttons =
            [
             { btn: ADMIN_USERS_BUTTON, txt: "Users", lnk: "/users" },
             { btn: ADMIN_SCORING_WEEKS_BUTTON, txt: "Scoring Weeks", lnk: "/weeks" }
            ]
        navbar << 
            vertical_divider <<
            drop_down("Admin", selected_button, admin_buttons)
      end

      navbar <<
        "</ul>" <<
        "<ul class='nav pull-right'>" <<
         vertical_divider <<
         drop_down("Hi " + current_user.first_name + "!", selected_button,
             [{ btn: EDIT_PROFILE_BUTTON, txt: "Edit Profile", lnk: "/profile", icon: "edit" },
              { type: "divider" },
              { txt: "Sign out", lnk: "/logout", icon: "eject" }]) <<
        "</ul>"
    else
      navbar << "<div class='brand brandctr'>Top Chef Rotiss</div>"
    end
    navbar << "</div></div>"
    return navbar.html_safe
  end

  def get_buttons(button_maps)
    buttons = []
    button_maps.each { |button_map|
      buttons << button_map[:btn]
      if button_map[:sub]
        buttons.push(*get_buttons(button_map[:sub]))
      end
    }
    return buttons
  end

  def drop_down(dropdown_text, selected_button, button_maps)
    drop_down_html = "<li class='dropdown"
    # if selected_button in list of child buttons, then add "active" class
    if get_buttons(button_maps).include?(selected_button)
      drop_down_html << " active"
    end
    drop_down_html <<
      "'>
         <a href='#' class='dropdown-toggle profiledropdown' data-toggle='dropdown'>
           " + dropdown_text + "&nbsp<b class='caret'></b>
         </a>" <<
         drop_down_list(selected_button, button_maps) <<
       "</li>"
    return drop_down_html
  end

  def drop_down_list(selected_button, button_maps)
    list_html = "<ul class='dropdown-menu'>"
    # construct child buttons
    button_maps.each do |button_map|
      if button_map[:type] == "divider"
        list_html << horizontal_divider
      else
        list_html << button_link(button_map[:btn], button_map[:txt],
                                      button_map[:lnk], selected_button, button_map[:icon],
                                      button_map[:sub])
      end
    end
    list_html << "</ul>"
  end

  def button_link(navigation_button, button_text, link_text, selected_button, icon = nil,
                  submenu_buttons = nil)
    button_html = "<li class='"
    if (selected_button == navigation_button) ||
       (submenu_buttons && get_buttons(submenu_buttons).include?(selected_button))
      button_html << " active "
    end
    if submenu_buttons
      button_html << " dropdown-submenu "
    end
    button_html << "'><a href='" + link_text + "'>"
    if icon
      button_html << "<i class='icon-" + icon + "'></i>&nbsp&nbsp"
    end
    button_html << button_text + "</a>"

    if submenu_buttons
      button_html << drop_down_list(selected_button, submenu_buttons)
    end
    button_html << "</li>"
    return button_html
  end

  def horizontal_divider
    return "<li class='divider'></li>"
  end

  def vertical_divider
    return "<li class='divider-vertical'></li>"
  end
end