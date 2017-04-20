require 'curl/curb_core_ffi'
require 'curl/errors'

module Curl
  class Multi
    
    class << self
      # call-seq:
      #   Curl::Multi.get(['url1','url2','url3','url4','url5'], :follow_location => true) do|easy|
      #     easy
      #   end
      # 
      # Blocking call to fetch multiple url's in parallel.
      def get(urls, easy_options={}, multi_options={}, &blk)
        url_confs = []
        urls.each do|url|
          url_confs << {:url => url, :method => :get}.merge(easy_options)
        end
        self.http(url_confs, multi_options) {|c,code,method| blk.call(c) if blk }
      end

      # call-seq:
      #
      #   Curl::Multi.post([{:url => 'url1', :post_fields => {'field1' => 'value1', 'field2' => 'value2'}},
      #                     {:url => 'url2', :post_fields => {'field1' => 'value1', 'field2' => 'value2'}},
      #                     {:url => 'url3', :post_fields => {'field1' => 'value1', 'field2' => 'value2'}}],
      #                    { :follow_location => true, :multipart_form_post => true },
      #                    {:pipeline => Curl::CURLPIPE_HTTP1}) do|easy|
      #     easy_handle_on_request_complete
      #   end
      # 
      # Blocking call to POST multiple form's in parallel.
      # 
      # urls_with_config: is a hash of url's pointing to the postfields to send 
      # easy_options: are a set of common options to set on all easy handles
      # multi_options: options to set on the Curl::Multi handle
      #
      def post(urls_with_config, easy_options={}, multi_options={}, &blk)
        url_confs = []
        urls_with_config.each do|uconf|
          url_confs << uconf.merge(:method => :post).merge(easy_options)
        end
        self.http(url_confs, multi_options) {|c,code,method| blk.call(c) }
      end

      # call-seq:
      #
      #   Curl::Multi.put([{:url => 'url1', :put_data => "some message"},
      #                    {:url => 'url2', :put_data => IO.read('filepath')},
      #                    {:url => 'url3', :put_data => "maybe another string or socket?"],
      #                    {:follow_location => true},
      #                    {:pipeline => Curl::CURLPIPE_HTTP1}) do|easy|
      #     easy_handle_on_request_complete
      #   end
      # 
      # Blocking call to POST multiple form's in parallel.
      # 
      # urls_with_config: is a hash of url's pointing to the postfields to send 
      # easy_options: are a set of common options to set on all easy handles
      # multi_options: options to set on the Curl::Multi handle
      #
      def put(urls_with_config, easy_options={}, multi_options={}, &blk)
        url_confs = []
        urls_with_config.each do|uconf|
          url_confs << uconf.merge(:method => :put).merge(easy_options)
        end
        self.http(url_confs, multi_options) {|c,code,method| blk.call(c) }
      end


      # call-seq:
      #
      # Curl::Multi.http( [
      #   { :url => 'url1', :method => :post,
      #     :post_fields => {'field1' => 'value1', 'field2' => 'value2'} },
      #   { :url => 'url2', :method => :get,
      #     :follow_location => true, :max_redirects => 3 },
      #   { :url => 'url3', :method => :put, :put_data => File.open('file.txt','rb') },
      #   { :url => 'url4', :method => :head }
      # ], {:pipeline => Curl::CURLPIPE_HTTP1})
      #
      # Blocking call to issue multiple HTTP requests with varying verb's.
      #
      # urls_with_config: is a hash of url's pointing to the easy handle options as well as the special option :method, that can by one of [:get, :post, :put, :delete, :head], when no verb is provided e.g. :method => nil -> GET is used
      # multi_options: options for the multi handle 
      # blk: a callback, that yeilds when a handle is completed
      #
      def http(urls_with_config, multi_options={}, &blk)
        m = Curl::Multi.new

        # maintain a sane number of easy handles
        multi_options[:max_connects] = max_connects = multi_options.key?(:max_connects) ? multi_options[:max_connects] : 10

        free_handles = [] # keep a list of free easy handles

        # configure the multi handle
        multi_options.each { |k,v| m.send("#{k}=", v) }
        callbacks = [:on_progress,:on_debug,:on_failure,:on_success,:on_redirect,:on_body,:on_header]

        add_free_handle = proc do|conf, easy|
          c       = conf.dup # avoid being destructive to input
          url     = c.delete(:url)
          method  = c.delete(:method)
          headers = c.delete(:headers)

          easy    = Curl::Easy.new if easy.nil?

          easy.url = url

          # assign callbacks
          callbacks.each do |cb|
            cbproc = c.delete(cb)
            easy.send(cb,&cbproc) if cbproc
          end

          case method
          when :post
            fields = c.delete(:post_fields)
            # set the post post using the url fields
            easy.post_body = fields.map{|f,k| "#{easy.escape(f)}=#{easy.escape(k)}"}.join('&')
          when :put
            easy.put_data = c.delete(:put_data)
          when :head
            easy.head = true
          when :delete
            easy.delete = true
          when :get
          else
            # XXX: nil is treated like a GET
          end

          # headers is a special key
          headers.each {|k,v| easy.headers[k] = v } if headers
 
          #
          # use the remaining options as specific configuration to the easy handle
          # bad options should raise an undefined method error
          #
          c.each { |k,v| easy.send("#{k}=",v) }

          easy.on_complete {|curl|
            free_handles << curl
            blk.call(curl,curl.response_code,method) if blk
          }
          m.add(easy)
        end

        max_connects.times do
          conf = urls_with_config.pop
          add_free_handle.call conf, nil
          break if urls_with_config.empty?
        end

        consume_free_handles = proc do
          # as we idle consume free handles
          if urls_with_config.size > 0 && free_handles.size > 0
            easy = free_handles.pop
            conf = urls_with_config.pop
            add_free_handle.call conf, easy
          end
        end

        if urls_with_config.empty?
          m.perform
        else
          until urls_with_config.empty?
            m.perform do
              consume_free_handles.call
            end
            consume_free_handles.call
          end
          free_handles = nil
        end
      end

      # call-seq:
      #
      # Curl::Multi.download(['http://example.com/p/a/t/h/file1.txt','http://example.com/p/a/t/h/file2.txt']){|c|}
      #
      # will create 2 new files file1.txt and file2.txt
      # 
      # 2 files will be opened, and remain open until the call completes
      #
      # when using the :post or :put method, urls should be a hash, including the individual post fields per post
      #
      def download(urls,easy_options={},multi_options={},download_paths=nil,&blk)
        errors = []
        procs = []
        files = []
        urls_with_config = []
        url_to_download_paths = {}

        urls.each_with_index do|urlcfg,i|
          if urlcfg.is_a?(Hash)
            url = url[:url]
          else
            url = urlcfg
          end

          if download_paths and download_paths[i]
            download_path = download_paths[i]
          else
            download_path = File.basename(url)
          end

          file = lambda do|dp|
            file = File.open(dp,"wb")
            procs << (lambda {|data| file.write data; data.size })
            files << file
            file
          end.call(download_path)

          if urlcfg.is_a?(Hash)
            urls_with_config << urlcfg.merge({:on_body => procs.last}.merge(easy_options))
          else
            urls_with_config << {:url => url, :on_body => procs.last, :method => :get}.merge(easy_options)
          end
          url_to_download_paths[url] = {:path => download_path, :file => file} # store for later
        end

        if blk
          # when injecting the block, ensure file is closed before yielding
          Curl::Multi.http(urls_with_config, multi_options) do |c,code,method|
            info = url_to_download_paths[c.url]
            begin
              file = info[:file]
              files.reject!{|f| f == file }
              file.close
            rescue => e
              errors << e
            end
            blk.call(c,info[:path])
          end
        else
          Curl::Multi.http(urls_with_config, multi_options)
        end

      ensure
        files.each {|f|
          begin
            f.close
          rescue => e
            errors << e
          end
        }
        raise errors unless errors.empty?
      end


      def default_timeout(*args)
      end

      def error(code)
        if clz = Err::MULTI_ERROR_MAP[code]
          return [clz, Core.multi_strerror(code)]
        else
          return [Err::UnknownError, "An unknown CURL Multi error occurred (mcode: #{code})"]
        end
      end      
    end

    def initialize
      @active = 0
      @running = 0      
      @timeout = ::FFI::MemoryPointer.new(:long)
      @timeval = Core::Timeval.new
      @fd_read = Core::FDSet.new
      @fd_write = Core::FDSet.new
      @fd_excep = Core::FDSet.new
      @max_fd = ::FFI::MemoryPointer.new(:int)      
    end    

    # call-seq:
    # multi = Curl::Multi.new
    # easy = Curl::Easy.new('url')
    #
    # multi.add(easy)
    #
    # Add an easy to the multi stack
    def add(curl)
      # make sure this isn't already added
      return nil if easies.include?(curl)

      curl.setup

      mcode = Core.multi_add_handle(handle, curl.handle)
      if mcode != :CALL_MULTI_PERFORM && mcode != :OK
        raise_error(mcode)
      end
      
      curl.multi = self
      easies << curl
    end

    def running?
      easies.size > 0 || (!defined?(@running_count) || running_count > 0)
    end    

    def requests(*args)
    end

    def pipeline=(*args)
    end

    def max_connects=(*args)
    end      

    def idle?(*args)
    end

    def cancel!(*args)
    end            

    def verbose?(*args)
    end

    # call-seq:
    # multi = Curl::Multi.new
    # easy1 = Curl::Easy.new('url')
    # easy2 = Curl::Easy.new('url')
    #
    # multi.add(easy1)
    # multi.add(easy2)
    #
    # multi.perform do
    #  # while idle other code my execute here
    # end
    #
    # Run multi handles, looping selecting when data can be transfered
    def perform(*args)
      yield if block_given?
      while running?
        run
        timeout = get_timeout
        next if timeout == 0
        reset_fds
        set_fds(timeout)
        yield if block_given?
      end
      nil
    end

    def remove(*args)
    end

    # The underlying FFI handle to the multi. Leave this alone.
    # It would be private but easy needs it right now...
    #
    # If the handle hasn't been snagged yet, this sets it up
    # as an autopointer that should take care of cleanup automagically.
    def handle
      @handle ||= FFI::AutoPointer.new(Core.multi_init, Core.method(:multi_cleanup)) 
    end

    def easies
      @easies ||= []
    end        

    private
    # Get timeout.
    #
    # @example Get timeout.
    #   multi.get_timeout
    #
    # @return [ Integer ] The timeout.
    #
    # @raise [ Ethon::Errors::MultiTimeout ] If getting the timeout fails.
    def get_timeout
      code = Core.multi_timeout(handle, @timeout)
      raise_error(code) unless code == :OK
      timeout = @timeout.read_long
      timeout = 1 if timeout < 0
      timeout
    end

    # Reset file describtors.
    #
    # @example Reset fds.
    #   multi.reset_fds
    #
    # @return [ void ]
    def reset_fds
      @fd_read.clear
      @fd_write.clear
      @fd_excep.clear
    end

    # Set fds.
    #
    # @example Set fds.
    #   multi.set_fds
    #
    # @return [ void ]
    #
    # @raise [ Ethon::Errors::MultiFdset ] If setting the file descriptors fails.
    # @raise [ Ethon::Errors::Select ] If select fails.
    def set_fds(timeout)
      code = Core.multi_fdset(handle, @fd_read, @fd_write, @fd_excep, @max_fd)
      raise_error(code) unless code == :OK
      max_fd = @max_fd.read_int
      if max_fd == -1
        sleep(0.001)
      else
        @timeval[:sec] = timeout / 1000
        @timeval[:usec] = (timeout * 1000) % 1000000
        loop do
          code = Core.select(max_fd + 1, @fd_read, @fd_write, @fd_excep, @timeval)
          break unless code < 0 && ::FFI.errno == Errno::EINTR::Errno
        end
        raise Err::CurlError.new("select Errno: " + ::FFI.errno) if code < 0
      end
    end

    # Run.
    #
    # @example Run
    #   multi.run
    #
    # @return [ void ]
    def run
      running_count_pointer = FFI::MemoryPointer.new(:int)
      begin code = trigger(running_count_pointer) end while code == :CALL_MULTI_PERFORM
      check
    end

    # Trigger.
    #
    # @example Trigger.
    #   multi.trigger
    #
    # @return [ Symbol ] The Curl.multi_perform return code.
    def trigger(running_count_pointer)
      code = Core.multi_perform(handle, running_count_pointer)
      @running_count = running_count_pointer.read_int
      code
    end    

    # Check.
    #
    # @example Check.
    #   multi.check
    #
    # @return [ void ]
    def check
      msgs_left = ::FFI::MemoryPointer.new(:int)
      while true
        msg = Core.multi_info_read(handle, msgs_left)
        break if msg.null?
        next if msg[:code] != :done
        easy = easies.find { |e| e.handle == msg[:easy_handle] }
        easy.last_result_code = msg[:data][:multi_code]
        delete(easy)
        easy.complete
      end
    end

    def delete(easy)
      if easies.delete(easy)
        code = Core.multi_remove_handle(handle, easy.handle)
        raise_error(code) unless code == :OK
      end
    end

    def raise_error(mcode)  
      err = Multi.error(mcode)
      raise err.first.new(err.last)
    end

    def running_count
      @running_count ||= nil
    end    
  end
end
