class Api::V1::DepartmentsController < ApplicationController
  before_action :set_department, only: %i[show update destroy]
  before_action :restrict_user, only: %i[index show]

  def index
    deparments = Department.all

    render json: deparments, status: :ok
  end

  def show
    render json: @department, status: :ok
  end

  def create
    department_name = department_params[:name].strip.gsub(/\s+/, ' ')
    department = Department.new(department_params.merge(name: department_name))
    department_exists = Department.exists?(name: department_name)

    if !department_exists
      if department.save
        render json: department, status: :created
      else
        render json: {
                 errors: {
                   messages: department.errors.full_messages
                 }
               },
               status: :unprocessable_entity
      end
    else
      render json: {
               errors: {
                 messages: ['Department already exists.']
               }
             },
             status: :unprocessable_entity
    end
  end

  private

  def set_department
    @department = Department.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
             errors: {
               messages: ['Record not found.']
             }
           },
           status: :not_found
  end

  def department_params
    params.require(:department).permit(:name)
  end
end
