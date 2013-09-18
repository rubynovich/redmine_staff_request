module StaffRequestsHelper
  def company_name_for_select
    t(:company_name, scope: :staff_requiest)
  end

  def position_type_name_for_select
    t(:position_type_name, scope: :staff_requiest)
  end

  def employment_type_name_for_select
    t(:employment_type_name, scope: :staff_requiest)
  end

  def require_education_name_for_select
    t(:require_education_name, scope: :staff_requiest)
  end

  def status_id_for_select
    IssueStatus.order(:position)
  end

  def priority_id_for_select
    IssuePriority.order(:position).map{ |item| [item.name, item.id] }
  end

  def boss_id_for_select
    User.active.order(:lastname, :firstname).map{ |item| [item.name, item.id] }
  end

  def time_periods
    %w{yesterday last_week this_week last_month this_month last_year this_year}
  end

  def author_id_for_select
    User.where("#{User.table_name}.id IN (SELECT #{StaffRequest.table_name}.author_id FROM #{StaffRequest.table_name})").order(:lastname, :firstname)
  end
end
