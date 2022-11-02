class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, :email_verified?

  def verify_email
    email_token = params[:email_token]
    begin
      decoded = JsonWebToken.decode(email_token)
      @user = User.find_by_email(decoded[:user_email])
      raise ActiveRecord::RecordNotFound if !@user
    rescue ActiveRecord::RecordNotFound
      render json: {
               errors: {
                 messages: ['Record not found.']
               }
             },
             status: :not_found
    rescue JWT::ExpiredSignature
      render json: {
               errors: {
                 messages: [
                   'Token has expired. Please request a new one to continue.'
                 ]
               }
             },
             status: :unprocessable_entity
    rescue JWT::DecodeError
      render json: {
               errors: {
                 messages: ['Invalid token.']
               }
             },
             status: :unprocessable_entity
    else
      if @user.email_verified
        render json: {
                 errors: {
                   messages: ['Your email has already been verified.']
                 }
               },
               status: :accepted
      else
        @user.update(email_verified: true)
        render json: {
                 user: @user,
                 messages: ['Your email has been successfully verified!']
               },
               status: :ok
      end
    end
  end

  def sign_in
    @user = User.find_by_email(params[:email])
    if (@user&.authenticate(params[:password]))
      payload = { user_id: @user.id }
      exp = 7.days.from_now.to_i
      access_token = JsonWebToken.encode(payload, exp)
      render json: {
               user: @user,
               expiration: exp,
               access_token: access_token
             },
             status: :ok
    else
      render json: {
               errors: {
                 messages: [
                   'Invalid credentials. Please check your email and password'
                 ]
               }
             },
             status: :unauthorized
    end
  end
end