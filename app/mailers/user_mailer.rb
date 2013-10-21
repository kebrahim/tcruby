class UserMailer < ActionMailer::Base
  default from: "noreply@rotiss.com"

  # sends an email to all non-demo users showing all the picks during the specified week
  def weekly_pick(week, picks, current_pick)
    @week = week
    @picks = picks
    @current_pick = current_pick

    # send email to all non-demo users
    mail :to => User.where("role != 'demo'").pluck(:email),
         :subject => "Top Chef Rotiss - Week " + week.to_s + " Picks"
  end
end
