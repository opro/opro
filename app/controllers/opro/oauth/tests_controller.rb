class Opro::Oauth::TestsController < OproController
  allow_oauth!
  disallow_oauth! :only => [:destroy]

  def index

  end

  def show
    result = if valid_oauth?
      {:status => 200, :message => 'OAuth worked!', :params => params, :user_id => oauth_user.id }
    else
      {:status => :unauthorized, :message => "OAuth did not work :(  #{generate_oauth_error_message!}", :params => params}
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
      {:status => 200, :message => 'OAuth worked!', :params => params, :user_id => oauth_user.id }
    else
      {:status => :unauthorized, :message => "OAuth did not work :(  #{generate_oauth_error_message!}", :params => params}
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
      {:status => 200, :message => 'OH NO!!! OAuth is disabled on this action; this is bad', :params => params}
    else
      {:status => :unauthorized, :message => "OAuth is disabled on this action; this is the correct result!", :params => params}
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
end