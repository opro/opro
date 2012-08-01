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

  def read_file(name)
    name = OPRO_MD_ROOT + name
    File.open(name + '.md.erb' ).read.to_s
  end
end