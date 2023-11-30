class JobsController < ApplicationController
  before_action :set_project, only: [:index, :new, :show, :edit]
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  def index
    @jobs = Job.project_or_parent(@project)
  end

  def show
  end

  def new
    @job = Job.new(project_id: @project.id).with_all_time_budgets
  end

  def edit
    @job.with_all_time_budgets
  end

  def update
    if @job.update(remove_empty_time_budgets(job_params))
      redirect_to project_job_path(@job.project, @job)
    else
      render :edit
    end
  end

  def create
    if @job = Job.create(job_params)
      redirect_to project_job_path(@job.project, @job)
    else
      render :edit
    end
  end

  def destroy
    @project = @job.project
    if @job.destroy
      redirect_to project_jobs_path(@project)
    else
      render :show
    end
  end

  private

  def job_params
    params.require(:job).permit(
      :starts_on,
      :ends_on,
      :project_id,
      :budget,
      :name,
      :description,
      :category_id,
      time_budgets_attributes: [:id, :category_id, :hours, :job_id, :_destroy]
    )
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_job
    @job = Job.find(params[:id])
  end

  # If a time budget is set to 0, remove it
  def remove_empty_time_budgets(params)
    params[:time_budgets_attributes].each do |key, value|
      params[:time_budgets_attributes][key]["_destroy"] = true if params[:time_budgets_attributes][key]["hours"] == "0"
    end
    params
  end
end
