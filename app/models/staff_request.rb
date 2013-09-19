class StaffRequest < ActiveRecord::Base
  unloadable

  belongs_to :issue, dependent: :destroy
  has_one :status, through: :issue
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :boss, class_name: 'User', foreign_key: 'boss_id'
  belongs_to :priority, class_name: 'IssuePriority', foreign_key: 'priority_id'

  validates_presence_of :name, :author_id, :company_name, :department_name,
    :boss_id, :position_type_name, :employment_type_name, :require_education_name,
    :priority_id, :position_count, :require_program_skills,
    :functional_responsibilities

  before_create :add_issue
  after_create :add_approval_item

  scope :visible, lambda{
    if !User.current.admin? && !User.current.staff_manager?
      where("#{self.table_name}.author_id = ?", User.current.id)
    end
  }

  scope :issue_status, lambda {|q|
    if q.present?
      {:conditions =>
        ["#{self.table_name}.issue_id IN (SELECT #{Issue.table_name}.id FROM #{Issue.table_name} WHERE status_id=:status_id)",
        {:status_id => q}]}
    end
  }

  scope :issue_priority, lambda {|q|
    if q.present?
      {:conditions =>
        ["#{self.table_name}.issue_id IN (SELECT #{Issue.table_name}.id FROM #{Issue.table_name} WHERE priority_id=:priority_id)",
        {:priority_id => q}]}
    end
  }

  scope :like_field, lambda {|q, field|
    if q.present?
      {:conditions =>
        ["LOWER(#{field}) LIKE LOWER(:p)", "%#{q.to_s.downcase}%"]}
    end
  }

  scope :eql_field, lambda {|q, field|
    if q.present? && field.present?
      where(field => q)
    end
  }

  def add_issue
    setting = Setting[:plugin_redmine_staff_request]
    self.create_issue(
      status: IssueStatus.default,
      tracker_id: setting[:tracker_id],
      project_id: setting[:project_id],
      assigned_to_id: setting[:assigned_to_id],
      author: User.current,
      start_date: Date.today,
      due_date: Date.today + setting[:duration].to_i.days,
      priority_id: self.priority_id,
      subject: ::I18n.t('message_staff_request_subject', :name => self.name, :position_count => self.position_count),
      description: [:company_name, :department_name, :boss_name, :position_type_name,
        :position_type_comment, :employment_type_name, :require_education_name].map do |item|
          "*#{::I18n.t('field_' + item.to_s, :default => item.to_s.humanize)}:* #{self.send(item)}" if self.send(item).present?
        end.compact.join("\n") + "\n\n" +
        [:require_program_skills, :functional_responsibilities].map do |item|
          "*#{::I18n.t('field_' + item.to_s, :default => item.to_s.humanize)}:*\n#{self.send(item)}" if self.send(item).present?
        end.join("\n\n"),
      is_private: true
    )
  end

  def add_approval_item
    ApprovalItem.create(issue_id: self.issue_id, user_id: self.boss_id)
  rescue
  end

end
