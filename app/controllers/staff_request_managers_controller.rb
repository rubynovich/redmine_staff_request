class StaffRequestManagersController < ApplicationController
  unloadable
  layout 'admin'

  before_filter :require_admin
  before_filter :find_object, :only => [:edit, :update, :destroy]

  def index
    @collection = model_name.all(:order => "users.lastname, users.firstname", :include => :user).select(&:user)
  end

  def update
    @object.approvers << User.find(params[:approver_ids])

    redirect_to :action => 'edit', :id => params[:id]
  end

  def create
    users = User.find(params[:manager_ids])
    users.each do |user|
      model_name.create(:user_id => user.id)
    end
    redirect_to :action => 'index'
  end

  def destroy
    if params[:id].present?
      if params[:approver_id].present? && (user = User.find(params[:approver_id]))
        @object.approvers.delete(user)
        redirect_to :action => 'edit', :id => params[:id]
      else
        @object.destroy
        redirect_to :action => 'index'
      end
    else
      redirect_to :action => 'index'
    end
  end

  private
    def find_object
      @object = model_name.find(params[:id])
    end

    def model_name
      StaffRequestManager
    end
end
