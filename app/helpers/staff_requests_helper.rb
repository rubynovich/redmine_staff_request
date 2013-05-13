module StaffRequestsHelper
  def company_name_for_select
    t(:company_name, :scope => :staff_requiest)
  end

  def position_type_name_for_select
    t(:position_type_name, :scope => :staff_requiest)
  end

  def employment_type_name_for_select
    t(:employment_type_name, :scope => :staff_requiest)
  end

  def require_education_name_for_select
    t(:require_education_name, :scope => :staff_requiest)
  end

  def priority_for_select
    IssuePriority.all(:order => :position)
  end

  def time_periods
    %w{yesterday last_week this_week last_month this_month last_year this_year}
  end

  def author_id_for_select
    StaffRequest.select(:author_id).uniq.all.select(&:author_id).map(&:author)
  end
end
