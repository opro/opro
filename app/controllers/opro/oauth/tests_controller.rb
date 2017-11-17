class Opro::Oauth::TestsController < OproController
  allow_oauth!
  disallow_oauth! :only => [:destroy]

  def index

  end

  def show
    result = oauth_result(params)
    render_result(result)
  end

  def create
    result = oauth_result(params)
    render_result(result)
  end

  def destroy
    result = if valid_oauth?
      {status: 200, message: 'OH NO!!! OAuth is disabled on this action; this is bad', params: params}
    else
      {status: :unauthorized, message: "OAuth is disabled on this action; this is the correct result!", params: params}
    end
    render_result(result)
  end

  private

  def render_result(result)
    respond_to do |format|
      format.html do
        render :html => result.to_json, :status => result[:status], :layout => true
      end
      format.json do
        render :json => result, :status => result[:status]
      end
    end
  end

  def oauth_result(options)
    if valid_oauth?
      {status: 200, message: 'OAuth worked!', params: options, user_id: oauth_user.id }
    else
      {status: :unauthorized, message: "OAuth did not work :(  #{generate_oauth_error_message!}", params: params}
    end
  end
end
