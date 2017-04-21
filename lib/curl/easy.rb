require 'curl/curb_core_ffi'
require 'curl/errors'

module Curl
  class Easy
    class Error < StandardError
      attr_accessor :message, :code
      def initialize(code, msg)
        self.message = msg
        self.code = code
      end
    end

    class << self
      def error(code)
        if clz = Err::EASY_ERROR_MAP[code]
          return [clz, Core.easy_strerror(code)]
        else
          return [Err::UnknownError, "An unknown CURL error occurred"]
        end
      end
    end
    
    def initialize(url = nil)
      @url = url if !url.nil?

      # defaults
      @ssl_verify_peer = true
      @ssl_verify_host_integer = 1
      @use_netrc = false
      @unrestricted_auth = false
      @proxy_tunnel = false      
      @header_in_body = false
      @http_auth_types = :basic

      yield self if block_given?      
    end
          
    def body_str
      @body_str
    end    

    def header_str(*args)
      @header_str
    end

    def reset(*args)
    end

    def put_data=(*args)
    end

    def post_body=(*args)
    end

    def on_progress(&handler)
      old, @on_progress = @on_progress, handler
      old      
    end

    def on_header(&handler)
      old, @on_header = @on_header, handler
      old      
    end

    def on_body(&handler)
      old, @on_body = @on_body, handler
      old      
    end
    
    # call-seq:
    #   easy.on_complete {|easy| ... }                   => &lt;old handler&gt;
    #
    # Assign or remove the +on_complete+ handler for this Curl::Easy instance.
    # To remove a previously-supplied handler, call this method with no
    # attached block.
    #
    # The +on_complete+ handler is called when the request is finished.
    def on_complete(&handler)
      old, @on_complete = @on_complete, handler
      old      
    end

     # call-seq:
     #   easy.on_success { |easy| ... }                   => &lt;old handler&gt;
     #
     # Assign or remove the +on_success+ handler for this Curl::Easy instance.
     # To remove a previously-supplied handler, call this method with no
     # attached block.
     #
     # The +on_success+ handler is called when the request is finished with a
     # status of 20x
     def on_success(&handler)
      old, @on_success = @on_success, handler
      old      
    end

    # call-seq:
    #   easy.on_failure {|easy,code| ... }               => &lt;old handler&gt;
    #
    # Assign or remove the +on_failure+ handler for this Curl::Easy instance.
    # To remove a previously-supplied handler, call this method with no
    # attached block.
    #
    # The +on_failure+ handler is called when the request is finished with a
    # status of 50x
    def on_failure(&handler)
      old, @on_failure = @on_failure, handler
      old      
    end

    # call-seq:
    #  easy.on_missing {|easy,code| ... }                => &lt;old handler;&gt;
    #
    #  Assign or remove the on_missing handler for this Curl::Easy instance.
    #  To remove a previously-supplied handler, call this method with no attached
    #  block.
    #
    #  The +on_missing+ handler is called when request is finished with a 
    #  status of 40x
    def on_missing(&handler)
      old, @on_missing = @on_missing, handler
      old      
    end    

    # call-seq:
    #  easy.on_redirect {|easy,code| ... }                => &lt;old handler;&gt;
    #
    #  Assign or remove the on_redirect handler for this Curl::Easy instance.
    #  To remove a previously-supplied handler, call this method with no attached
    #  block.
    #
    #  The +on_redirect+ handler is called when request is finished with a 
    #  status of 30x
    def on_redirect(&handler)
      old, @on_redirect = @on_redirect, handler
      old      
    end

    # call-seq:
    #   easy.on_debug { |type, data| ... }               => &lt;old handler&gt;
    #
    # Assign or remove the +on_debug+ handler for this Curl::Easy instance.
    # To remove a previously-supplied handler, call this method with no
    # attached block.
    #
    # The +on_debug+ handler, if configured, will receive detailed information
    # from libcurl during the perform call. This can be useful for debugging.
    # Setting a debug handler overrides libcurl's internal handler, disabling
    # any output from +verbose+, if set.
    #
    # The type argument will match one of the Curl::Easy::CURLINFO_XXXX
    # constants, and specifies the kind of information contained in the
    # data. The data is passed as a String.
    def on_debug(&handler)
      old, @on_debug = @on_debug, handler
      old      
    end

    attr_accessor :username
    attr_accessor :password
    attr_accessor :userpwd

    attr_accessor :useragent

    def use_netrc=(bool)
      @use_netrc = (bool ? true : false)
    end

    def use_netrc?
      @use_netrc
    end

    def unrestricted_auth=(bool)
      @unrestricted_auth = (bool ? true : false)
    end
    
    def unrestricted_auth?
      @unrestricted_auth
    end

    def unescape(*args)
    end

    # TODO this should be readonly...
    attr_accessor :multi

    def ssl_verify_peer?
      @ssl_verify_peer
    end

    def ssl_verify_peer=(bool)
      @ssl_verify_peer = (bool ? true : false)
    end
    
    def resolve_mode(*args)
    end

    def headers=(headers)
      @headers = headers
    end

    def headers
      @headers ||= {}
    end

    def escape(*args)
    end

    def verbose?
    end

    attr_accessor :http_auth_types
    attr_accessor :proxy_auth_types
    attr_accessor :proxy_type
    attr_accessor :proxypwd

    attr_accessor :encoding

    def proxy_tunnel=(bool)
      @proxy_tunnel = (bool ? true : false)
    end

    def proxy_tunnel?
      @proxy_tunnel
    end

    def proxy_port=(port)
      if (!port.nil?)
        port = port.to_i
        raise ArgumentError.new("Invalid proxy port") unless port > 0 && port < 65536
      end
      @proxy_port = port
    end
    
    def proxy_port
      @proxy_port
    end

    def proxy_url
      @proxy_url
    end

    # The last Curl result code (a symbol)
    def last_result_code
      @last_result_code
    end
    
    # Last result as a numeric - API compatible
    def last_result
      Core.sym2num(last_result_code)
    end
    
    def local_port=(port)
      if (!port.nil?)
        port = port.to_i
        raise ArgumentError.new("Invalid local port") unless port > 0 && port < 65536
      end
      @local_port = port
    end
    
    def local_port
      @local_port
    end

    def local_port_range=(port)
      if (!port.nil?)
        port = port.to_i
        raise ArgumentError.new("Invalid local port range") unless port > 0 && port < 65536
      end
      @local_port_range = port
    end
    
    def local_port_range
      @local_port_range
    end

    def multipart_form_post=(bool)
      @multipart_form_post = (bool ? true : false)
    end
    
    def multipart_form_post?
      @multipart_form_post
    end

    attr_accessor :max_redirects
    attr_accessor :low_speed_time
    attr_accessor :low_speed_limit

    def fetch_file_time=(bool)
      @fetch_file_time = (bool ? true : false)
    end
    
    def fetch_file_time?
      @fetch_file_time
    end    
    
    def ignore_content_length=(bool)
      @ignore_content_length = (bool ? true : false)
    end
    
    def ignore_content_length?
      @ignore_content_length
    end

    def header_in_body=(bool)
      @header_in_body = (bool ? true : false)
    end
    
    def header_in_body?
      @header_in_body
    end

    def last_effective_url
      ptr = Core::OutPtr.new
      Core.easy_getinfo(handle, :effective_url,  ptr)

      # make a pointer from the out-int, get string, and dup to be safe.
      # The memory stays around until curl_easy_cleanup is called, butif the
      # string lasts longer there'll be a segfault at some random time later...
      #
      # This also isn't thread safe but I think it'd be a pretty pathological      
      # case that broke it. Still, I guess we'll see...
      #
      # nil return is intentional, btw!
      if !(s = ptr.to_pointer.read_string).empty?
        s.dup.force_encoding(__ENCODING__)
      end      
    end
    
    attr_accessor :timeout, :timeout_ms
    attr_accessor :connect_timeout, :connect_timeout_ms
    attr_accessor :dns_cache_timeout
    attr_accessor :ftp_response_timeout

    attr_accessor :cacert
    attr_accessor :cert
    attr_accessor :certtype
    attr_accessor :certpassword
    attr_accessor :cert_key

    def response_code
      ptr = Core::OutPtr.new
      res = Core.easy_getinfo(handle, :response_code, ptr)
      ptr.to_i
    end  

    # The underlying FFI handle to the multi. Leave this alone.
    # It would be private but easy needs it right now...
    def handle
      @handle ||= FFI::AutoPointer.new(Core.easy_init, Core.method(:easy_cleanup)) 
    end

    def close
      # TODO slists?
      # TODO this makes it segfault...
      #Core.easy_cleanup(handle)    
      #h = handle    # get new handle
      #multi = nil
    end    

    # TODO hide this, it's an implementation detail
    def setup
      url = @url
      @body_str = nil

      # TODO get headers
      # TODO get ftp commands

      if url.nil?
        raise(Err::CurlError.new("No URL Supplied"))
      end

      Core.easy_setopt(handle, :url, url)

      Core.easy_setopt(handle, :username, username) if !username.nil?
      Core.easy_setopt(handle, :password, password) if !password.nil?
      Core.easy_setopt(handle, :userpwd, userpwd) if !userpwd.nil?
      if use_netrc?
        Core.easy_setopt(handle, :netrc, :optional)
      else
        Core.easy_setopt(handle, :netrc, :ignored)
      end
      Core.easy_setopt(handle, :unrestricted_auth, unrestricted_auth? ? 1 : 0)
      
      
      Core.easy_setopt(handle, :httpauth, 16)
      # TODO Core.easy_setopt(handle, :HTTPAUTH, http_auth_types)
      

      Core.easy_setopt(handle, :proxy, proxy_url) if !proxy_url.nil?
      Core.easy_setopt(handle, :proxyuserpwd, proxypwd) if !proxypwd.nil?

      Core.easy_setopt(handle, :proxyport, proxy_port) if !proxy_port.nil?
      Core.easy_setopt(handle, :localpory, local_port) if !local_port.nil?
      Core.easy_setopt(handle, :localportrange, local_port_range) if !local_port_range.nil?

      Core.easy_setopt(handle, :encoding, encoding) if !encoding.nil?

      Core.easy_setopt(handle, :timeout, timeout) if !timeout.nil?
      Core.easy_setopt(handle, :timeout_ms, timeout_ms) if !timeout_ms.nil?
      Core.easy_setopt(handle, :connecttimeout, connect_timeout) if !connect_timeout.nil?
      Core.easy_setopt(handle, :connecttimeout_ms, connect_timeout_ms) if !connect_timeout_ms.nil?
      Core.easy_setopt(handle, :dns_cache_timeout, dns_cache_timeout) if !dns_cache_timeout.nil?
      Core.easy_setopt(handle, :ftp_response_timeout, ftp_response_timeout) if !ftp_response_timeout.nil?

      Core.easy_setopt(handle, :low_speed_limit, low_speed_limit) if !low_speed_limit.nil?
      Core.easy_setopt(handle, :low_speed_time, low_speed_limit) if !low_speed_time.nil?

      # General options
      Core.easy_setopt(handle, :header, header_in_body? ? 1 : 0)
      Core.easy_setopt(handle, :followlocation, follow_location? ? 1 : 0)
      Core.easy_setopt(handle, :maxredirs, max_redirects) if !max_redirects.nil?

      Core.easy_setopt(handle, :httpproxytunnel, proxy_tunnel? ? 1 : 0)
      Core.easy_setopt(handle, :filetime, fetch_file_time? ? 1 : 0)

      Core.easy_setopt(handle, :ssl_verifypeer, ssl_verify_peer? ? 1 : 0)
      Core.easy_setopt(handle, :ssl_verifyhost, ssl_verify_host? ? 1 : 0)

      # SSL
      Core.easy_setopt(handle, :sslcert, cert) if !cert.nil?
      Core.easy_setopt(handle, :sslcerttype, certtype) if !certtype.nil?
      Core.easy_setopt(handle, :sslcertpassword, certpassword) if !certpassword.nil?
      Core.easy_setopt(handle, :sslkey, cert_key) if !cert_key.nil?
      Core.easy_setopt(handle, :cainfo, cacert) if !cacert.nil?


      # CALLBACKS
      Core.easy_setopt_string_function(handle, :writefunction, method(:body_callback).to_proc)
      Core.easy_setopt_string_function(handle, :headerfunction, method(:header_callback).to_proc)
      if !@on_progress.nil?
        Core.easy_setopt_progress_function(handle, :progressfunction, method(:progress_callback).to_proc)
        Core.easy_setopt(handle, :noprogress, 0)
      else
        Core.easy_setopt(handle, :noprogress, 1)
      end

      # COOKIES
      if (cookies_enabled?)
        Core.easy_setopt(handle, :cookiejar, cookiejar) if !cookiejar.nil?
        Core.easy_setopt(handle, :cookiefile, cookiefile || nil) # "" = magic to just enable
      end

      Core.easy_setopt(handle, :cookie, cookies) if !cookies.nil?

      # TODO The metric fuck-ton of other setup that needs doing...
    end

    alias body body_str
    alias head header_str
    
    #
    # call-seq:
    #   easy.status  => String
    #
    def status
      # Matches the last HTTP Status - following the HTTP protocol specification 'Status-Line = HTTP-Version SP Status-Code SP Reason-Phrase CRLF'
      statuses = self.header_str.scan(/HTTP\/\d\.\d\s(\d+\s.*)\r\n/).map{ |match|  match[0] }
      statuses.last.strip
    end

    #
    # call-seq:
    #   easy.set :sym|Fixnum, value
    #
    # set options on the curl easy handle see http://curl.haxx.se/libcurl/c/curl_easy_setopt.html
    #
    def set(opt,val)
      opt = opt.to_i unless opt.is_a?(Symbol)

      if opt.is_a? Fixnum
        raise(TypeError.new("Unknown Curl Option")) unless optsym = Core::OPTION[opt]
      else
        optsym, opt = opt, Core.sym2num(opt)
      end

      begin
        Core.easy_setopt(handle, optsym, val)
      rescue TypeError
        raise TypeError, "Curb doesn't support setting #{optsym} [##{opt}] option"
      end
    end

    #
    # call-seq:
    #   easy.perform                                     => true
    #
    # Transfer the currently configured URL using the options set for this
    # Curl::Easy instance. If this is an HTTP URL, it will be transferred via
    # the configured HTTP Verb.
    #
    def perform
      self.multi = Curl::Multi.new if self.multi.nil?
      self.multi.add self
      ret = self.multi.perform
      self.multi.remove self

      if self.last_result_code != :e_ok && self.on_failure.nil?
        error = Curl::Easy.error(self.last_result)
        raise error.first.new(error.last)
      end

      true
    end

    #
    # call-seq:
    #
    # easy = Curl::Easy.new
    # easy.nosignal = true
    #
    def nosignal=(onoff)
      set :nosignal, !!onoff
    end

    #
    # call-seq:
    #   easy = Curl::Easy.new("url") do|c|
    #    c.delete = true
    #   end
    #   easy.perform
    #
    def delete=(onoff)
      set :customrequest, onoff ? 'DELETE' : nil
      onoff
    end
    #
    # call-seq:
    #
    #  easy = Curl::Easy.new("url")
    #  easy.version = Curl::HTTP_2_0
    #  easy.version = Curl::HTTP_1_1
    #  easy.version = Curl::HTTP_1_0
    #  easy.version = Curl::HTTP_NONE
    #
    def version=(http_version)
      set :http_version, http_version
    end

    # call-seq:
    #   easy.url                                         => string
    #
    # Obtain the URL that will be used by subsequent calls to +perform+.
    def url
      @url
    end

    #
    # call-seq:
    #   easy.url = "http://some.url/"                    => "http://some.url/"
    #
    # Set the URL for subsequent calls to +perform+. It is acceptable
    # (and even recommended) to reuse Curl::Easy instances by reassigning
    # the URL between calls to +perform+.
    #
    def url=(u)
      @url = u
    end

    #
    # call-seq:
    #   easy.proxy_url = string                          => string
    #
    # Set the URL of the HTTP proxy to use for subsequent calls to +perform+.
    # The URL should specify the the host name or dotted IP address. To specify
    # port number in this string, append :[port] to the end of the host name.
    # The proxy string may be prefixed with [protocol]:// since any such prefix
    # will be ignored. The proxy's port number may optionally be specified with
    # the separate option proxy_port .
    #
    # When you tell the library to use an HTTP proxy, libcurl will transparently
    # convert operations to HTTP even if you specify an FTP URL etc. This may have
    # an impact on what other features of the library you can use, such as
    # FTP specifics that don't work unless you tunnel through the HTTP proxy. Such
    # tunneling is activated with proxy_tunnel = true.
    #
    # libcurl respects the environment variables *http_proxy*, *ftp_proxy*,
    # *all_proxy* etc, if any of those is set. The proxy_url option does however
    # override any possibly set environment variables.
    #
    # Starting with libcurl 7.14.1, the proxy host string given in environment
    # variables can be specified the exact same way as the proxy can be set with
    # proxy_url, including protocol prefix (http://) and embedded user + password.
    #
    def proxy_url=(url)
      @proxy_url = url
    end

    def ssl_verify_host=(value)
      value = 1 if value.class == TrueClass
      value = 0 if value.class == FalseClass
      @ssl_verify_host_integer=value
    end

    def ssl_verify_host
      @ssl_verify_host_integer
    end    

    #
    # call-seq:
    #   easy.ssl_verify_host?                            => boolean
    #
    # Deprecated: call easy.ssl_verify_host instead
    # can be one of [0,1,2]
    #
    # Determine whether this Curl instance will verify that the server cert
    # is for the server it is known as.
    #
    def ssl_verify_host?
      ssl_verify_host.nil? ? false : (ssl_verify_host > 0)
    end

    #
    # call-seq:
    #   easy.interface = string                          => string
    #
    # Set the interface name to use as the outgoing network interface.
    # The name can be an interface name, an IP address or a host name.
    #
    def interface=(value)
      set :interface, value
    end

    #
    # call-seq:
    #   easy.userpwd = string                            => string
    #
    # Set the username/password string to use for subsequent calls to +perform+.
    # The supplied string should have the form "username:password"
    #
    def userpwd=(value)
      set :userpwd, value
    end

    #
    # call-seq:
    #   easy.proxypwd = string                           => string
    #
    # Set the username/password string to use for proxy connection during
    # subsequent calls to +perform+. The supplied string should have the
    # form "username:password"
    #
    def proxypwd=(value)
      set :proxyuserpwd, value
    end

    # call-seq:
    #   easy.enable_cookies = boolean                    => boolean
    #
    # Configure whether the libcurl cookie engine is enabled for this Curl::Easy
    # instance.
    def enable_cookies=(bool)
      @enable_cookies = (bool ? true : false)
    end

    # call-seq:
    #   easy.enable_cookies?                             => boolean
    #
    # Determine whether the libcurl cookie engine is enabled for this
    # Curl::Easy instance.
    def enable_cookies?
      @enable_cookies
    end

    alias cookies_enabled? enable_cookies?

    # call-seq:
    #   easy.cookies                                     => "name1=content1; name2=content2;"
    #
    # Obtain the cookies for this Curl::Easy instance.
    def cookies
      @cookies
    end    

    #
    # call-seq:
    #   easy.cookies = "name1=content1; name2=content2;" => string
    #
    # Set cookies to be sent by this Curl::Easy instance. The format of the string should
    # be NAME=CONTENTS, where NAME is the cookie name and CONTENTS is what the cookie should contain.
    # Set multiple cookies in one string like this: "name1=content1; name2=content2;" etc.
    #
    def cookies=(value)
      @cookies = value
    end

    # call-seq:
    #   easy.cookiefile                                  => string
    #
    # Obtain the cookiefile file for this Curl::Easy instance.
    def cookiefile
      @cookiefile
    end    

    #
    # call-seq:
    #   easy.cookiefile = string                         => string
    #
    # Set a file that contains cookies to be sent in subsequent requests by this Curl::Easy instance.
    #
    # *Note* that you must set enable_cookies true to enable the cookie
    # engine, or this option will be ignored.
    #
    def cookiefile=(value)
      @cookiefile = value
    end

    # call-seq:
    #   easy.cookiejar                                   => string
    #
    # Obtain the cookiejar file to use for this Curl::Easy instance.
    def cookiejar
      @cookiejar
    end

    #
    # call-seq:
    #   easy.cookiejar = string                          => string
    #
    # Set a cookiejar file to use for this Curl::Easy instance.
    # Cookies from the response will be written into this file.
    #
    # *Note* that you must set enable_cookies true to enable the cookie
    # engine, or this option will be ignored.
    #
    def cookiejar=(value)
      @cookiejar = value
    end

    #
    # call-seq:
    #  easy = Curl::Easy.new("url") do|c|
    #   c.head = true
    #  end
    #  easy.perform
    #
    def head=(onoff)
      set :nobody, onoff
    end

    #
    # call-seq:
    #   easy.follow_location = boolean                   => boolean
    #
    # Configure whether this Curl instance will follow Location: headers
    # in HTTP responses. Redirects will only be followed to the extent
    # specified by +max_redirects+.
    #
    def follow_location=(onoff)
      @follow_location = (onoff ? true : false)
    end

    # call-seq:
    #   easy.follow_location?                            => boolean
    #
    # Determine whether this Curl instance will follow Location: headers
    # in HTTP responses.
    def follow_location?
      @follow_location
    end

    #
    # call-seq:
    #   easy.http_head                                   => true
    #
    # Request headers from the currently configured URL using the HEAD
    # method and current options set for this Curl::Easy instance. This
    # method always returns true, or raises an exception (defined under
    # Curl::Err) on error.
    #
    def http_head
      set :nobody, true
      ret = self.perform
      set :nobody, false
      ret
    end

    #
    # call-seq:
    #   easy.http_get                                    => true
    #
    # GET the currently configured URL using the current options set for
    # this Curl::Easy instance. This method always returns true, or raises
    # an exception (defined under Curl::Err) on error.
    #
    def http_get
      set :httpget, true
      http :GET
    end
    alias get http_get

    #
    # call-seq:
    #   easy.http_delete
    #
    # DELETE the currently configured URL using the current options set for
    # this Curl::Easy instance. This method always returns true, or raises
    # an exception (defined under Curl::Err) on error.
    #
    def http_delete
      self.http :DELETE
    end
    alias delete http_delete

    def http(verb)
      Core.easy_setopt(handle, :customrequest, verb.to_s)
      begin
        return self.perform
      ensure
        Core.easy_setopt(handle, :customrequest, nil)
      end
    end

    #
    # call-seq:
    #   easy.http_put(url, data) {|c| ... }
    #
    # see easy.http_put
    #
    def http_put(data)
    end

    #
    # call-seq:
    #   easy.http_post(url, "some=urlencoded%20form%20data&and=so%20on") => true
    #   easy.http_post(url, "some=urlencoded%20form%20data", "and=so%20on", ...) => true
    #   easy.http_post(url, "some=urlencoded%20form%20data", Curl::PostField, "and=so%20on", ...) => true
    #   easy.http_post(url, Curl::PostField, Curl::PostField ..., Curl::PostField) => true
    #
    # POST the specified formdata to the currently configured URL using
    # the current options set for this Curl::Easy instance. This method
    # always returns true, or raises an exception (defined under
    # Curl::Err) on error.
    #
    # If you wish to use multipart form encoding, you'll need to supply a block
    # in order to set ignore_content_length true. See #http_post for more
    # information.
    #
    def http_post(*args)
    end      
    
    alias post http_post
    alias put http_put

    def inspect
      if url
        "#<Curl::Easy #{url[0..49]}>"
      else        
        "#<Curl::Easy>"
      end
    end

    class << self

      #
      # call-seq:
      #   Curl::Easy.perform(url) { |easy| ... }           => #&lt;Curl::Easy...&gt;
      #
      # Convenience method that creates a new Curl::Easy instance with
      # the specified URL and calls the general +perform+ method, before returning
      # the new instance. For HTTP URLs, this is equivalent to calling +http_get+.
      #
      # If a block is supplied, the new instance will be yielded just prior to
      # the +http_get+ call.
      #
      def perform(*args)
        c = Curl::Easy.new(*args)
        yield c if block_given?
        c.perform
        c
      end

      #
      # call-seq:
      #   Curl::Easy.http_get(url) { |easy| ... }          => #&lt;Curl::Easy...&gt;
      #
      # Convenience method that creates a new Curl::Easy instance with
      # the specified URL and calls +http_get+, before returning the new instance.
      #
      # If a block is supplied, the new instance will be yielded just prior to
      # the +http_get+ call.
      #
      def http_get(*args)
        c = Curl::Easy.new(*args)
        yield c if block_given?
        c.http_get
        c
      end

      #
      # call-seq:
      #   Curl::Easy.http_head(url) { |easy| ... }         => #&lt;Curl::Easy...&gt;
      #
      # Convenience method that creates a new Curl::Easy instance with
      # the specified URL and calls +http_head+, before returning the new instance.
      #
      # If a block is supplied, the new instance will be yielded just prior to
      # the +http_head+ call.
      #
      def http_head(*args)
        c = Curl::Easy.new(*args)
        yield c if block_given?
        c.http_head
        c
      end

      #
      # call-seq:
      #   Curl::Easy.http_put(url, data) {|c| ... }
      #
      # see easy.http_put
      #
      def http_put(url, data)
        c = Curl::Easy.new url
        yield c if block_given?
        c.http_put data
        c
      end

      #
      # call-seq:
      #   Curl::Easy.http_post(url, "some=urlencoded%20form%20data&and=so%20on") => true
      #   Curl::Easy.http_post(url, "some=urlencoded%20form%20data", "and=so%20on", ...) => true
      #   Curl::Easy.http_post(url, "some=urlencoded%20form%20data", Curl::PostField, "and=so%20on", ...) => true
      #   Curl::Easy.http_post(url, Curl::PostField, Curl::PostField ..., Curl::PostField) => true
      #
      # POST the specified formdata to the currently configured URL using
      # the current options set for this Curl::Easy instance. This method
      # always returns true, or raises an exception (defined under
      # Curl::Err) on error.
      #
      # If you wish to use multipart form encoding, you'll need to supply a block
      # in order to set ignore_content_length true. See #http_post for more
      # information.
      #
      def http_post(*args)
        url = args.shift
        c = Curl::Easy.new url
        yield c if block_given?
        c.http_post(*args)
        c
      end

      #
      # call-seq:
      #   Curl::Easy.http_delete(url) { |easy| ... }       => #&lt;Curl::Easy...&gt;
      #
      # Convenience method that creates a new Curl::Easy instance with
      # the specified URL and calls +http_delete+, before returning the new instance.
      #
      # If a block is supplied, the new instance will be yielded just prior to
      # the +http_delete+ call.
      #
      def http_delete(*args)
        c = Curl::Easy.new(*args)
        yield c if block_given?
        c.http_delete
        c
      end

      # call-seq:
      #   Curl::Easy.download(url, filename = url.split(/\?/).first.split(/\//).last) { |curl| ... }
      #
      # Stream the specified url (via perform) and save the data directly to the
      # supplied filename (defaults to the last component of the URL path, which will
      # usually be the filename most simple urls).
      #
      # If a block is supplied, it will be passed the curl instance prior to the
      # perform call.
      #
      # *Note* that the semantics of the on_body handler are subtly changed when using
      # download, to account for the automatic routing of data to the specified file: The
      # data string is passed to the handler *before* it is written
      # to the file, allowing the handler to perform mutative operations where
      # necessary. As usual, the transfer will be aborted if the on_body handler
      # returns a size that differs from the data chunk size - in this case, the
      # offending chunk will *not* be written to the file, the file will be closed,
      # and a Curl::Err::AbortedByCallbackError will be raised.
      def download(url, filename = url.split(/\?/).first.split(/\//).last, &blk)
        curl = Curl::Easy.new(url, &blk)

        output = if filename.is_a? IO
          filename.binmode if filename.respond_to?(:binmode)
          filename
        else
          File.open(filename, 'wb')
        end

        begin
          old_on_body = curl.on_body do |data|
            result = old_on_body ?  old_on_body.call(data) : data.length
            output << data if result == data.length
            result
          end
          curl.perform
        ensure
          output.close rescue IOError
        end

        return curl
      end
    end

    # Allow the incoming cert string to be file:password
    # but be careful to not use a colon from a windows file path
    # as the split point. Mimic what curl's main does
    if respond_to?(:cert=)
      alias_method :native_cert=, :cert=
      def cert=(cert_file)
        pos = cert_file.rindex(':')
        if pos && pos > 1
          self.native_cert= cert_file[0..pos-1]
          self.certpassword= cert_file[pos+1..-1]
        else
          self.native_cert= cert_file
        end
        self.cert
      end
    end


    ################################## PRIVATE ###########################################    
    private

    def last_result_code=(code)
      @last_result_code = code
    end

    #################### CALLBACK IMPLEMENTATIONS ############################
    # Note: these MUST return a Numeric, or "hilarity" will ensue. FFI uses NUM2LL to convert
    # the return value, so if you get weird TypeErrors with an incomplete stack trace, check 
    # this first.
    #
    # Curl expects the return to be size * n, anything else signals a write error.
    #
    # Originally the idea was to pass through the proc in WRITEDATA and retrieve
    # it here, but that could cause problems if the proc gets GC'd (or moved e.g. on JRuby)
    # so now we don't do that...

    # Passed to Curl to handle body data.
    def body_callback(str, size, n, ignored)
      if (@on_body)
        @on_body.call(str)
      else
        (@body_str ||= "") << str
      end
      size * n
    end     

    # Passed to Curl to handle header data.
    def header_callback(str, size, n, ignored)
      if (@on_header)
        @on_header.call(str)
      else
        (@header_str ||= "") << str
      end
      size * n
    end

    def progress_callback(ignored, dltotal, dlnow, ultotal, ulnow)
      ret = 0
      if (@on_progress)
        begin
          @on_progress.call([dltotal, dlnow, ultotal, ulnow])
        rescue => exception
          ret = -1
        end        
      end  
      ret    
    end    

    public
    ################## END CALLBACK IMPLEMENTATIONS ##########################

    # Multi calls this when we're done, and it handles calling the handler procs...
    def handle_easy_completed(curl_result)
      code, ex = self.response_code, nil
      self.last_result_code = curl_result

      # Curb API stipulates empty header when no headers received, 
      # or (I think) if we've handled them with a handler, so ensure that.
      @header_str ||= ""

      begin; @on_complete.call(self)         if @on_complete                                ; rescue => ex; end;
      begin; @on_failure.call(self, code)    if @on_failure    && curl_result != 0          ; rescue => ex; end; 
      begin; @on_redirect.call(self, code)   if @on_redirect   && code > 300 && code < 400  ; rescue => ex; end;
      begin; @on_missing.call(self, code)    if @on_missing    && code > 400 && code < 500  ; rescue => ex; end;
      begin; @on_failure.call(self, code)    if @on_failure    && code > 500 && code <= 999 ; rescue => ex; end;
      begin
        @on_success.call(self) if @on_success && ((code > 200 && code < 300) || code == 0)  
      rescue => ex; end

      warn "Uncaught exception from callback" if ex
    end    

  end
end
