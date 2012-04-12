require 'erb'
require 'bluecloth'

OPRO_MD_ROOT=File.join(File.dirname(__FILE__), '../../views/oauth/docs/markdown/')


class Oauth::DocsController < ApplicationController
  helper_method :render_doc

  def index
  end

  def show
    @doc = params[:id]
  end

  def render_doc(name)
    str = read_file(name.to_s)
    str = parse_erb(str)
    str = parse_markdown(str)
    str.html_safe
  end

  private

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