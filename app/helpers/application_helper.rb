module ApplicationHelper

  TABLE_CLASS = 'table table-striped table-bordered table-condensed center dashboardtable
                 vertmiddle'
  TABLE_SMALL_CLASS = 'table table-striped table-bordered table-condensed center dashboardtable
                 vertmiddle smallfonttable'
  TABLE_STRIPED_CLASS = 'table table-dash-striped table-bordered table-condensed center
                 dashboardtable vertmiddle'

  # Shows the specified notice as an alert and displays it as an error, if the notice string starts
  # with "Error"
  def show_notice_as_alert(notice)
    return show_notice_as_alert_with_class_string(notice, nil)
  end

  # Shows the specified notice as an alert and displays it as an error, if the notice string starts
  # with "Error", including the specified class string.
  def show_notice_as_alert_with_class_string(notice, class_string)
    noticeHTML = ""
    if !notice.nil? && !notice.empty?
      if notice.starts_with?("Error:")
        noticeHTML << "<div class='alert alert-error alert-center"
      else
        noticeHTML << "<div class='alert alert-success alert-center"
      end
      if !class_string.nil? && !class_string.empty?
        noticeHTML << " " + class_string
      end
      noticeHTML << "'><button type='button' class='close' data-dismiss='alert'>&times;</button>" +
                    "<strong>" + notice + "</strong></div>"
    end
    return noticeHTML.html_safe
  end

  # shows the specified list of errors as an error alert
  def show_errors_as_alert(errors)
    return show_errors_as_alert_with_class_string(errors, nil)
  end

  # shows the specified list of errors as an error alert, with the additional classes
  def show_errors_as_alert_with_class_string(errors, class_string)
    errors_html = "<div class='alert alert-error alert-center"
    if !class_string.nil? && !class_string.empty?
      errors_html << " " + class_string
    end
    errors_html << "'><button type='button' class='close' data-dismiss='alert'>&times;</button>" +
                    "<strong>Errors occurred: "
    errors.each {
      errors_html << errors.join("; ")
    }
    errors_html << "</strong></div>"
    return errors_html.html_safe
  end

  # returns a link for a column header, which sorts by the specified column
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

  # returns a select tag, allowing user to choose from a list of weeks, from 1 to the specified
  # current week, marking the specified selected week as selected
  def display_week_chooser(current_week, selected_week)
    week_chooser_html = "<label>Select week:</label>&nbsp&nbsp
                         <select class='input-large' id='week_chooser'>"
    1.upto(current_week) { |week|
      week_chooser_html << "<option value=" + week.to_s
      week_chooser_html << " selected" if week == selected_week
      week_chooser_html << ">Week " + week.to_s + "</option>"
    }
    week_chooser_html << "</select>"
    return week_chooser_html.html_safe
  end

  def chef_selector(chefs, selected_chef, has_no_chef_selection, has_label)
    chef_chooser_html = ""
    if has_label
      chef_chooser_html << "<label for='chef_chooser'>Select chef:</label>&nbsp&nbsp"
    end
    chef_chooser_html << "<select id='chef_chooser' class='input-large' name='chef_id'>"
    if has_no_chef_selection
      chef_chooser_html << "<option value=0>-- Select Chef --</option>"
    end

    # chefs
    chefs.each { |chef|
      chef_chooser_html << "<option value=" + chef.id.to_s
      if selected_chef && chef.id == selected_chef.id
        chef_chooser_html << " selected"
      end
      chef_chooser_html << ">" + chef.full_name + "</option>"
    }
    chef_chooser_html << "</select>"
    return chef_chooser_html.html_safe
  end

  def stat_chef_multi_selector(label_name, stat_abbr, chefs)
    chef_chooser_html = "<label for='" + stat_abbr + "'>" + label_name + ":</label>&nbsp&nbsp
                         <select multiple='multiple' class='multiselect input-large'
                                 id='" + stat_abbr + "' name='" + stat_abbr + "[]'>"
    # chefs
    chefs.each { |chef|
      chef_chooser_html << "<option value=" + chef.id.to_s
      stat = @stat_abbr_to_stat_map[stat_abbr]
      if @chef_id_to_stat_id_map.has_key?(chef.id) &&
         @chef_id_to_stat_id_map[chef.id].include?(stat.id)
        chef_chooser_html << " selected"
      end
      chef_chooser_html << ">" + chef.first_name + "</option>"
    }
    chef_chooser_html << "</select>"
    return chef_chooser_html.html_safe    
  end

  def record_selector
    record_chooser_html = "<select class='input-medium' name='record'>
                           <option value=0>-- Select Result --</option>"
    # records
    [:win, :loss].each { |record|
      record_chooser_html << "<option value=" + Pick::record_abbreviation(record) +  ">" + 
          Pick::record_string(record) + "</option>"
    }
    record_chooser_html << "</select>"
    return record_chooser_html.html_safe
  end

  # returns a select tag, allowing user to choose from the list of specified users, marking the
  # specified selected user as selected
  def user_selector(users, selected_user)
    user_chooser_html = "<label>Select team:</label>&nbsp&nbsp
                         <select class='input-large' id='user_chooser'>"
    users.each { |user|
      user_chooser_html << "<option value=" + user.id.to_s
      user_chooser_html << " selected" if user.id == selected_user.id
      user_chooser_html << ">" + user.full_name + "</option>"
    }
    user_chooser_html << "</select>"
    return user_chooser_html.html_safe
  end

  # returns the week when the chef with the specified array of chefstats was eliminated, or nil if
  # none was found
  def week_eliminated(chefstats)
    chefstats.each { |chefstat|
      if chefstat.stat.abbreviation == Stat::ELIMINATED_ABBR
        return chefstat.week
      end
    }
    return nil
  end

  # returns a link for a column header, which sorts by the specified column
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

  def chefstat_class(chefstats, win_stat_abbreviations, lose_stat_abbr)
    if chefstats
      chefstats.each { |chefstat|
        if win_stat_abbreviations.include?(chefstat.stat.abbreviation)
          return "green-cell"
        elsif chefstat.stat.abbreviation == lose_stat_abbr
          return "red-cell"
        end
      }
    end
    return ""
  end
end
