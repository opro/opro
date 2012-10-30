require 'test_helper'

class DocsControllerTest < ActiveSupport::IntegrationCase
  DOCS_PATH = File.join(File.dirname(__FILE__), '../../app/views/opro/oauth/docs/markdown/*.md.erb')

  test 'renders index' do
    visit oauth_docs_path
    assert_equal '/oauth_docs', current_path
  end

  test 'renders show' do
    Dir[DOCS_PATH].each do |file|
      doc =  file.split('/').last.gsub('.md.erb', '')
      doc_path = oauth_doc_path(:id => doc)
      visit doc_path
      assert_equal doc_path, current_path
      refute has_content?("The page you were looking for doesn't exist")
    end
  end
end
