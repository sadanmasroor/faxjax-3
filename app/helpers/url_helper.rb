module UrlHelper
  include TagHelper

  class Request
    attr_accessor :host, :port
    def initialize host="localhost", port=nil
      @host, @port = *[host, port]
    end
  end

  def canonize req, options={}
    r=Request.new req.host, req.port
    r.port = nil if options[:protocol] == 'https'
    r
  end
  def _protocol options={}
    options[:protocol] || 'http'
  end
  def _port(req, options={})
    if req.port.nil? || options[:protocol] == 'https'
      80
    else
      req.port
    end
  end
  def _query options = {}
    parms=[]
    unless options[:controller].nil?
      parms << ''
      parms << options[:controller]
      unless options[:action].nil?
        parms << options[:action]
        unless options[:id].nil?
          parms << options[:id]
        end
      end
    end
    parms.join '/' 
  end
  
  def _url req, options ={}
    req = canonize req, options
    uri=URI::HTTP.new _protocol(options), nil, req.host, _port(req, options), nil, _query(options), nil, nil, nil
    uri.to_s
  end
  
  #  form helper method
  def absolute_url_for options={}
    options[:protocol] = 'http' unless RAILS_ENV == "development"
    _url @request, options
  end
  
  def anchor url, options={}, &blk
    options[:href] = url
    _tga(:a, options, &blk)
  end
  
  def anchor_for options = {}, &blk
    href = ['', options[:controller], options[:action], options[:id]].reject {|e| e.nil?}.join('/')
    _tga(:a, {:href=>href}, &blk)
  end
end
