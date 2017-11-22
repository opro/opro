require 'erb'
require 'kramdown'

OPRO_MD_ROOT = File.join(File.dirname(__FILE__), '../../../views/opro/oauth/docs/markdown/')

class Opro::Oauth::DocsController < OproController
  before_action :set_protocol!
  helper_method :render_doc

  def index
  end

  def show
    @doc  = params[:id]
    render :file => default_404, :status => 404 and return unless md_exists?(@doc)
  end

  def render_doc(name)
    str = read_file(name.to_s)
    str = parse_erb(str)
    str = parse_markdown(str)
    str.html_safe
  end

  private

  def default_404
    Rails.root.join("public", "404")
  end

  def set_protocol!
    @protocol = Rails.env.production? ? "https" : "http"
  end

  def parse_erb(str)
    ERB.new(str).result(binding)
  end

  def parse_markdown(str)
    Kramdown::Document.new(str).to_html
  end

  def doc_md_filename(name)
    OPRO_MD_ROOT + name + '.md.erb'
  end

  def md_exists?(name)
    File.exists?(doc_md_filename(name.to_s))
  end

  def read_file(name)
    File.open(doc_md_filename(name)).read.to_s
  end
end
