require 'test_helper'

class OproTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Opro
  end



end



class OproSetupTest < ActiveSupport::TestCase

  test 'setting auth_strategy :devise' do
    Opro.setup do |config|
      config.auth_strategy :devise
    end
    assert Opro.login_method.present?
    assert Opro.logout_method.present?
  end

end