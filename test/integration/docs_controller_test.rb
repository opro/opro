require 'test_helper'

class DocsControllerTest < ActiveSupport::IntegrationCase
  test 'renders index' do
    visit oauth_docs_path
    assert_equal '/oauth_docs', current_path
  end

  test 'renders show' do
    [:curl, :oauth, :quick_start].each do |doc|
      doc_path = oauth_doc_path(:id => doc)
      visit doc_path
      assert_equal doc_path, current_path
    end
  end
end
