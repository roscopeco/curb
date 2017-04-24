module Curl
  class PostField
    class << self
      # call-seq:
      #   Curl::PostField.file(name, local_file_name) => #&lt;Curl::PostField...&gt;
      #   Curl::PostField.file(name, local_file_name, remote_file_name = local_file_name) => #&lt;Curl::PostField...&gt;
      #   Curl::PostField.file(name, remote_file_name) { |field| ... } => #&lt;Curl::PostField...&gt;
      # 
      # Create a new Curl::PostField for a file upload field, supplying the local filename
      # to read from, and optionally the remote filename (defaults to the local name).
      # 
      # The block form allows a block to supply the content for this field, called
      # during the perform. The block should return a ruby string with the field
      # data.
      def file(*args, &blk)
        if args.length == 3
          if blk
            # have block, ignore local file        
            new(args[0], nil, nil, nil, args[2], blk)
          else
            new(args[0], nil, nil, args[1], args[2], nil)
          end          
        elsif args.length == 2
          if blk
            # have block and remote
            new(args[0], nil, nil, nil, args[1], blk)
          else
            # have local only
            new(args[0], nil, nil, args[1], args[1], nil)
          end
        else
          raise ArgumentError, "Incorrect number of arguments (expected 2 or 3)"
        end
      end
      
      # call-seq:
      #   Curl::PostField.content(name, content) => #&lt;Curl::PostField...&gt;
      #   Curl::PostField.content(name, content, content_type = nil) => #&lt;Curl::PostField...&gt;
      #   Curl::PostField.content(name, content_type = nil) { |field| ... } => #&lt;Curl::PostField...&gt;
      # 
      # Create a new Curl::PostField, supplying the field name, content,
      # and, optionally, Content-type (curl will attempt to determine this if
      # not specified).
      # 
      # The block form allows a block to supply the content for this field, called
      # during the perform. The block should return a ruby string with the field
      # data.
      def content(*args, &blk)
        if args.length == 3
          # have content-type, ignore block(?)
          new(args[0], args[1], args[2], nil, nil, nil)
        elsif args.length == 2
          if blk
            # have content-type and block
            new(args[0], nil, args[1], nil, nil, blk)
          else
            # have name and content
            new(args[0], args[1], nil, nil, nil, nil)
          end
        elsif args.length == 1 and blk
          # have name and content block
          new(args[0], nil, nil, nil, nil, blk)
        else
          raise ArgumentError, "Incorrect number of arguments (expected 2 or 3)"
        end
      end

      private

      def new(*args); super; end
    end

    attr_reader :name, :remote_file, :local_file, :content_type, :content

    def to_s
      if (name = @name) && name.respond_to?(:to_s)
        name = Curl.escape(name)
        content = if @content_proc
          # TODO original curb does this, but maybe shouldn't? What about side-effects?
          # however, easy.http_post relies on it...
          @content_proc.call(self)
        elsif @content
          @content
        elsif @local_file
          @local_file
        elsif @remote_file
          @remote_file
        else
          ""
        end

        if content.respond_to?(:to_s)
          content = content.to_s
        else
          raise RuntimeError, "postfield(#{name}) is not a string and does not respond_to to_s"
        end

        name + '=' + Curl.escape(content)
      else
        raise Curl::Err::InvalidPostField, "Cannot convert unnamed field to string, make sure your field name responds_to :to_s"
      end
    end

    def content_proc(&blk)
      old, @content_proc = @content_proc, blk
      old
    end

    # API Compatibility
    alias :set_content_proc :content_proc

    def get_content_proc
      @content_proc
    end    

    private 

    def initialize(name, content, content_type, local_file, remote_file, blk)
      @name, @content, @content_type, @local_file, @remote_file, @content_proc = name, content, content_type, local_file, remote_file, blk
    end
  end  
end
