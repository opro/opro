require 'erb'
require 'bluecloth'

OPRO_MD_ROOT=File.join(File.dirname(__FILE__), '../../../views/opro/oauth/docs/markdown/')


class Opro::Oauth::DocsController < OproController
  helper_method :render_doc

  def index
    @protocol = protocol
  end

  def show
    @protocol = protocol
    @doc = params[:id]
    if !File.exists?(doc_md_filename(@doc.to_s))
      render :file => "#{Rails.root}/public/404", :status => 404
      return
    end
  end

  def render_doc(name)
    str = read_file(name.to_s)
    str = parse_erb(str)
    str = parse_markdown(str)
    str.html_safe
  end

  private

  def protocol
    Rails.env.production? ? "https" : "http"
  end

  def parse_erb(str)
    ERB.new(str).result(binding)
  end

  def parse_markdown(str)
    BlueCloth.new(str).to_html
  end

  def doc_md_filename(name)
    OPRO_MD_ROOT + name + '.md.erb'
  end

  def read_file(name)
    File.open(doc_md_filename(name)).read.to_s
  end
end