require 'test_helper'

class OproClientAppTest < ActiveSupport::TestCase

  test "generate_unique_app_id" do
    client_app  = create_client_app
    app_id      = client_app.app_id
    new_app_id  = Opro::Oauth::ClientApp.generate_unique_app_id(app_id)
    assert_not_equal app_id, new_app_id
  end
end
