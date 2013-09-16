class StaffRequestManagersController < ApplicationController
  unloadable
  layout 'admin'

  before_filter :require_admin
  before_filter :find_object, :only => [:edit, :update, :destroy]
  before_filter :find_manager_candidates, :only => [:index, :autocomplete_for_manager]
  before_filter :find_approver_candidates, :only => [:edit, :autocomplete_for_approver]

  def index
    @collection = model_name.visible.all(:order => "users.lastname, users.firstname", :include => :user).select(&:user)
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

  def autocomplete_for_manager
    render :layout => false
  end

  def autocomplete_for_approver
    render :layout => false
  end

  private
    def find_object
      @object = model_name.find(params[:id])
    end

    def find_manager_candidates
      @manager_candidates = User.active.not_staff_request_managers.like(params[:q]).all(:order => "lastname, firstname")
    end

    def find_approver_candidates
      find_object
      @approver_candidates = User.active.not_approvers(@object).like(params[:q]).all(:order => "lastname, firstname")
    end

    def model_name
      StaffRequestManager
    end
end
