class CreateStaffRequests < ActiveRecord::Migration
  def change
    create_table :staff_requests do |t|
      t.string :name
      t.integer :author_id
      t.integer :issue_id
      t.string :company_name
      t.string :department_name
      t.string :boss_name
      t.string :position_type_name
      t.string :position_type_comment
      t.string :employment_type_name
      t.string :require_education_name
      t.integer :priority_id
      t.integer :position_count
      t.text :require_program_skills
      t.text :require_experience
      t.text :functional_responsibilities
      t.datetime :updated_on
      t.datetime :created_on
    end
  end
end
