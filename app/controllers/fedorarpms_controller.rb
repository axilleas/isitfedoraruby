class FedorarpmsController < ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    @page_title = 'Fedora RPMs'
    @rpms = FedoraRpm.paginate(page: params[:page], per_page: 50)
                     .order(sort_column + ' ' + sort_direction)
  end

  def show
    @name = params[:id]
    @rpm = FedoraRpm.find_by_name! @name
    @page_title = @rpm.name
    @dependencies = @rpm.dependency_packages.uniq
    @dependents = @rpm.dependent_packages.uniq
    # We can register a global error handler inside the application controller for this.
    rescue ActiveRecord::RecordNotFound
      redirect_to action: 'not_found'
  end

  def not_found
    @rpm = params[:id]
    @results = FedoraRpm.where('name LIKE ?', "%#{@rpm}%")
  end

  def full_deps
    @name = params[:id]
    @rpm = FedoraRpm.find_by_name(@name)
    respond_to do |format|
      format.html
    end
  end

  def full_dependencies
    @name = params[:id]
    @rpm = FedoraRpm.find_by_name(@name)
    respond_to do |format|
      format.json { render json: @rpm.json_dependencies }
    end
  end

  def full_dependents
    @name = params[:id]
    @rpm = FedoraRpm.find_by_name(@name)
    respond_to do |format|
      format.json { render json: @rpm.json_dependents }
    end
  end

  def by_owner
    @name = params[:id]
    @rpms = FedoraRpm.where('owner LIKE ?', @name)
    @uptodate = @rpms.select { |rpm| rpm.up_to_date? }
    @outdated = @rpms.reject { |rpm| rpm.up_to_date? }
  end

  def badge
    @user_name = params[:id]
    rpms = FedoraRpm.where('owner LIKE ?', @user_name)
    @total = rpms.size
    @commits = 0
    @most = nil
    rpms.each do |rpm|
      @commits += rpm.commits
      @most = rpm if @most.nil? || rpm.commits > @most.commits
    end
    @most = @most.shortname
    render layout: false
  end

  private

  def sort_column
    %w(name commits last_commit_date owner).include?(params[:sort]) ?
        params[:sort] : 'name'
  end

  def sort_direction
    %w(asc desc).include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
