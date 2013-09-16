class StaffRequestsController < ApplicationController
  unloadable

  helper :journals
  helper :issues
  helper :sort
  include SortHelper

  before_filter :require_staff_request_manager
  before_filter :find_object, :only => [:edit, :update, :show, :destroy]
  before_filter :new_object, :only => [:index, :new, :create]

  def index
    sort_init 'created_on', 'desc'
    sort_update %w(name company_name department_name boss_name position_type_name employment_type_name require_education_name created_on)

    @limit = per_page_option

    @scope = object_class_name.
      visible.
      issue_status(params[:status_id]).
      issue_priority(params[:priority_id]).
      like_field(params[:name], :name).
      like_field(params[:department_name], :department_name).
      like_field(params[:boss_name], :boss_name).
      eql_field(params[:company_name], :company_name).
      eql_field(params[:position_type_name], :position_type_name).
      eql_field(params[:employment_type_name], :employment_type_name).
      eql_field(params[:require_education_name], :require_education_name).
      eql_field(params[:created_on], :created_on).
      eql_field(params[:author_id], :author_id).
      time_period(params[:time_period_created_on], :created_on)

    @count = @scope.count
    @pages = Paginator.new(self, @count, @limit, params[:page])
    @offset ||= @pages.current.offset
    @collection = @scope.limit(@limit).offset(@offset).order(sort_clause).all
  end

  def create
    @object.author_id = User.current.id
    if @object.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => :show, :id => @object.id
    else
      render :action => :new
    end
  end

  def update
    if @object.update_attributes(params[object_sym])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => :show, :id => @object.id
    else
      render :action => :edit
    end
  end

  def destroy
    flash[:notice] = l(:notice_successful_delete) if @object.destroy
    redirect_to :action => :index
  end

  def show
    if @issue = @object.issue
      @journals = get_journals
    end
  end

  def autocomplete_for_name
    autocomplete_for_field(:name)
  end

  def autocomplete_for_department_name
    autocomplete_for_field(:department_name)
  end


  def autocomplete_for_boss_name
    autocomplete_for_field(:boss_name)
  end


  private
    def object_class_name
      StaffRequest
    end

    def object_sym
      :staff_request
    end

    def find_object
      @object = object_class_name.find(params[:id])
    end

    def new_object
      @object = object_class_name.new(params[object_sym])
    end

    def get_journals
      journals = @issue.journals.includes(:user, :details).reorder("#{Journal.table_name}.id ASC").all
      journals.each_with_index {|j,i| j.indice = i+1}
      journals.reject!(&:private_notes?) unless User.current.allowed_to?(:view_private_notes, @issue.project)
      journals.reverse! if User.current.wants_comments_in_reverse_order?
      journals
    end

    def require_staff_request_manager
      (render_403; return false) unless User.current.staff_request_manager?
    end

    def autocomplete_for_field(field)
      completions = StaffRequest.where("#{field} LIKE ?", "#{params[:term]}%").
        order(field).
        uniq.
        limit(10).
        map{|l| { 'id' => l.id, 'label' => l.send(field), 'value' => l.send(field)} }
      render :text => completions.to_json, :layout => false
    end

end
