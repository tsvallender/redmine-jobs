class JobsController < ApplicationController
  before_action :set_project, only: [:index, :new, :show, :edit]
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  def index
    @jobs = Job.all
  end

  def show
  end

  def new
    @job = Job.new
  end

  def edit
  end

  def update
    if @job.update(job_params)
      redirect_to @job
    else
      render :edit
    end
  end

  def create
    if @job = Job.create(job_params)
      redirect_to @job
    else
      render :edit
    end
  end

  def destroy
    if @job.destroy
      redirect_to jobs_path(project_id: @project.id)
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
      :external_project_id,
      :name,
      :description
    )
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_job
    @job = Job.find(params[:id])
  end
end
