require 'curl/curb_core_ffi'
require 'curl/easy'
require 'curl/multi'
require 'uri'
require 'cgi'

# expose shortcut methods
module Curl

  # These should be managed from the Rake 'release' task.
  CURB_VERSION    = "2.0.1.7"
  CURB_VER_NUM    = 2017
  CURB_VER_MAJ    = 2
  CURB_VER_MIN    = 0
  CURB_VER_MIC    = 1
  CURB_VER_PATCH  = 7
  
  HTTP_ANY = 0
  HTTP_1_0 = 1
  HTTP_1_1 = 2
  HTTP_2_0 = 3
  HTTP_2_TLS = 4
  HTTP_2_PRIOR_KNOWLEDGE = 5
      
  def self.http(verb, url, post_body=nil, put_data=nil, &block)
    handle = Thread.current[:curb_curl] ||= Curl::Easy.new
    handle.reset
    handle.url = url
    handle.post_body = post_body if post_body
    handle.put_data = put_data if put_data
    yield handle if block_given?
    handle.http(verb)
    handle
  end

  def self.get(url, params={}, &block)
    http :GET, urlalize(url, params), nil, nil, &block
  end

  def self.post(url, params={}, &block)
    http :POST, url, postalize(params), nil, &block
  end

  def self.put(url, params={}, &block)
    http :PUT, url, nil, postalize(params), &block
  end

  def self.delete(url, params={}, &block)
    http :DELETE, url, postalize(params), nil, &block
  end

  def self.patch(url, params={}, &block)
    http :PATCH, url, postalize(params), nil, &block
  end

  def self.head(url, params={}, &block)
    http :HEAD, urlalize(url, params), nil, nil, &block
  end

  def self.options(url, params={}, &block)
    http :OPTIONS, urlalize(url, params), nil, nil, &block
  end

  def self.urlalize(url, params={})
    query_str = params.map {|k,v| "#{URI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
    if url.match(/\?/) && query_str.size > 0
      "#{url}&#{query_str}"
    elsif query_str.size > 0
      "#{url}?#{query_str}"
    else
      url
    end
  end

  def self.postalize(params={})
    params.respond_to?(:map) ? URI.encode_www_form(params) : (params.respond_to?(:to_s) ? params.to_s : params)
  end

  def self.reset
    Thread.current[:curb_curl] = Curl::Easy.new
  end

  def self.escape(str)
    # TODO checkver > 0x070f04, use curl_escape if not
    ptr = Core.escape(str, str.length)

    result = if (ptr.null?)
      ""
    else
      str = ptr.read_string.force_encoding(__ENCODING__)
      str = str.dup
      str[0] = str[0]   # TODO verify this forces a copy
      str
    end

    Core.free(ptr)
    result
end

  def self.unescape(str)
    # TODO checkver > 0x070f04, use curl_escape if not
    ptr = Core.unescape(str, str.length)

    result = if (ptr.null?)
      ""
    else
      str = ptr.read_string.force_encoding(__ENCODING__)
      str = str.dup
      str[0] = str[0]   # TODO verify this forces a copy
      str
    end

    Core.free(ptr)
    result
  end
end
