class StaffRequest < ActiveRecord::Base
  unloadable

  belongs_to :issue, :dependent => :destroy
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  belongs_to :priority, :class_name => 'IssuePriority', :foreign_key => 'priority_id'

  after_create :create_issue

  scope :like_field, lambda {|q, field|
    if q.present?
      {:conditions =>
        ["LOWER(:field) LIKE :p OR :field LIKE :p",
        {:field => field, :p => "%#{q.to_s.downcase}%"}]}
    end
  }

  scope :eql_field, lambda {|q, field|
    if q.present? && field.present?
      where(field => q)
    end
  }

  scope :time_period, lambda {|q, field|
    today = Date.today
    if q.present? && field.present?
      {:conditions =>
        (case q
          when "yesterday"
            ["? BETWEEN ? AND ?",
              field,
              2.days.ago,
              1.day.ago]
          when "today"
            ["? BETWEEN ? AND ?",
              field,
              1.day.ago,
              1.day.from_now]
          when "last_week"
            ["? BETWEEN ? AND ?",
              field,
              1.week.ago - today.wday.days,
              1.week.ago - today.wday.days + 1.week]
          when "this_week"
            ["? BETWEEN ? AND ?",
              field,
              1.week.from_now - today.wday.days - 1.week,
              1.week.from_now - today.wday.days]
          when "last_month"
            ["? BETWEEN ? AND ?",
              field,
              1.month.ago - today.day.days,
              1.month.ago - today.day.days + 1.month]
          when "this_month"
            ["? BETWEEN ? AND ?",
              field,
              1.month.from_now - today.day.days - 1.month,
              1.month.from_now - today.day.days]
          when "last_year"
            ["? BETWEEN ? AND ?",
              field,
              1.year.ago - today.yday.days,
              1.year.ago - today.yday.days + 1.year]
          when "this_year"
            ["? BETWEEN ? AND ?",
              field,
              1.year.from_now - today.yday.days - 1.year,
              1.year.from_now - today.yday.days]
          else
            {}
        end)
      }
    end
  }

  def create_issue
    setting = Setting[:plugin_redmine_staff_request]
    issue_id = Issue.create(
      :status => IssueStatus.default,
      :tracker_id => setting[:tracker_id],
      :project_id => setting[:project_id],
      :assigned_to_id => setting[:assigned_to_id],
      :author => User.current,
      :start_date => Date.today,
      :due_date => Date.today + setting[:duration].to_i.days,
      :priority => self.priority,
      :subject => ::I18n.t('message_staff_request_subject', :name => self.name, :position_count => self.position_count),
      :description =>
        [:company_name, :department_name, :boss_name, :position_type_name,
        :position_type_comment, :employment_type_name, :require_education_name].map do |item|
          "*#{::I18n.t('field_' + item.to_s, :default => item.to_s.humanize)}:* #{self.send(item)}" if self.send(item).present?
        end.compact.join("\n") + "\n\n" +
        [:require_program_skills, :require_experience, :functional_responsibilities].map do |item|
          "*#{::I18n.t('field_' + item.to_s, :default => item.to_s.humanize)}:*\n#{self.send(item)}" if self.send(item).present?
        end.join("\n\n")
    ).try(:id)
    self.update_attribute(:issue_id, issue_id)
  end
end
