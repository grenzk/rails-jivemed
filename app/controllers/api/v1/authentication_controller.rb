class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, except: [:request_email_token]
  skip_before_action :is_email_verified?

  def request_email_token
    if @current_user.email_verified
      render json: {
               errors: {
                 messages: ['Your email has already been verified.']
               }
             },
             status: :accepted
    else
      payload = { user_email: @current_user.email }
      new_email_token = JsonWebToken.encode(payload, 24.hours.from_now)
      render json: {
               messages: ['A confirmation email has been sent!'],
               email_token: new_email_token
             },
             status: :ok
    end
  end

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
      access_token_expiration = 7.days.from_now.to_i
      access_token = JsonWebToken.encode(payload, access_token_expiration)
      render json: {
               user: @user,
               access_token: access_token,
               access_token_expiration: access_token_expiration
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
