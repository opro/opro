class Oauth::TestsController < ApplicationController
  allow_oauth!
  disallow_oauth! :only => [:destroy]

  def index

  end

  def show
    result = if valid_oauth?
      {:status => 200, :message => 'OAuth Worked!!', :params => params, :user_id => oauth_user.id }
    else
      {:status => 401, :message => "OAuth Did not Work :(  #{generate_oauth_error_message!}", :params => params}
    end

    respond_to do |format|
      format.html do
        render :text => result.to_json,   :status => result[:status], :layout => true
      end
      format.json do
        render :json => result, :status => result[:status]
      end
    end
  end

  def create
    result = if valid_oauth?
      {:status => 200, :message => 'OAuth Worked!!', :params => params, :user_id => oauth_user.id }
    else
      {:status => 401, :message => "OAuth Did not Work D:  #{generate_oauth_error_message!}", :params => params}
    end

    respond_to do |format|
      format.html do
        render :text => result.to_json,   :status => result[:status], :layout => true
      end
      format.json do
        render :json => result, :status => result[:status]
      end
    end
  end

  def destroy
    result = if valid_oauth?
      {:status => 200, :message => 'OHNO!!! OAuth is Disabled on this Action, this is bad', :params => params}
    else
      {:status => 401, :message => "Oauth is Disabled on this Action, this is the correct result!", :params => params}
    end

    respond_to do |format|
      format.html do
        render :text => result.to_json,   :status => result[:status], :layout => true
      end
      format.json do
        render :json => result, :status => result[:status]
      end
    end
  end

  private

  def generate_oauth_error_message!
    msg = ""
    msg << ' - No OAuth Token Provided!'    if params[:access_token].blank?
    msg << ' - Allow OAuth set to false!'   if allow_oauth? == false
    msg << ' - OAuth user not found!'       if oauth_user.blank?
    generate_oauth_permissions_error_message!(msg)
    msg
  end

  def generate_oauth_permissions_error_message!(msg = '')
    if !oauth_client_has_permissions?
      msg << ' - OAuth client not permitted'
      oauth_required_permissions.each do |permission|
        msg << "- #{permission} permission required;" unless oauth_client_has_permission?(permission)
      end
    end
    msg
  end

end