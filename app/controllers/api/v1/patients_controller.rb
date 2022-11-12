class Api::V1::PatientsController < ApplicationController
  skip_before_action :authenticate_request, :email_verified, only: [:create]
  before_action :restrict_user, only: [:index]

  def index
    patients =
      User
        .all
        .select { |user| user.role == patient_role }
        .map { |user| { user: user, role: user.role } }

    render json: { users: patients }, status: :ok
  end

  def create
    patient = User.new(patient_params.merge(role_id: patient_role.id))

    if patient.save
      payload = { user_email: patient.email }
      email_token = JsonWebToken.encode(payload, 24.hours.from_now)

      render json: { user: patient, email_token: email_token }, status: :created
    else
      render json: {
               errors: {
                 messages: patient.errors.full_messages
               }
             },
             status: :unprocessable_entity
    end
  end

  private

  def patient_params
    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end
end
