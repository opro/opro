require 'test_helper'

class DocsControllerTest < ActiveSupport::IntegrationCase
  test 'renders' do
    visit oauth_docs_path
    assert_equal '/oauth_docs', current_path
  end
end
