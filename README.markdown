# Curb FFI - FFI port of Curb, the popular Ruby libcurl bindings.

This branch is a work-in-progress port of the original Curb library to an FFI backend. The aims
of this project are:

  * To remove all C code and hard-dependencies on MRI, allowing Curb to be used
    anywhere there's a working implementation of Ruby FFI.

  * To completely replicate the API of Curb 0.9.x, warts and all. This should be a 100%
    no-work drop-in for the C extension, no matter how you're using it.

  * To retain and reuse as much of the original Curb ruby code as possible.

  * To maintain the current standard of documentation in Curb (It's pretty well documented -
    this mostly means not forgetting to copy the doc over from the C code to Ruby).

  * To fully support JRuby and Rubinius if possible, and work on all major
    platforms (i.e. Linux, Windows and Mac).

  * To merge into the main project (at http://github.com/taf2/curb) and replace
    the C codebase (The C may be maintained as a 'legacy' codebase, or this
    may become a new major version - we haven't really discussed that yet).

This branch is currently under active development, and is far from 100% complete - many
things don't work as they should, or just plain don't work. Development is currently
based on the reasonably-extensive tests from Curb, with a view to getting them to run,
then to pass, on a test-by-test basis.

At the time of writing, the focus is on `tc_curl_easy.rb`. Right now we're down to
__2 fails, 2 errors__ (on MRI/Windows/x64). 

If you're interested in playing with the library, then don't forget that __you can help__!

  * File bugs when things go wrong - help us know where we should focus our attention.

  * Make Pull Requests when you can fix them.

  * Let us know you're using it - the more interest there is, the greater our motivation!

Currently known issues (not exhaustive):

  * Segfaults (_at least_ Windows and Linux, most likely across the board) in certain 
    Curl::Multi functions. These cause both MRI and the JVM to core dump.

  * Curl version checking is not yet implemented. Make sure you're using a recent
    version of curl, or we may blindly call functions that don't exist in your lib.

  * Most of the code in Core is a mess. This will improve in time.

  * Lots of little stuff, and some not-so-little stuff, is still not implemented.

The following is the original Curb readme.

# Curb - Libcurl bindings for Ruby [![Build Status](https://travis-ci.org/taf2/curb.svg?branch=master)](https://travis-ci.org/taf2/curb)

* [rubydoc rdoc](http://www.rubydoc.info/github/taf2/curb/)
* [github project](http://github.com/taf2/curb/tree/master)

Curb (probably CUrl-RuBy or something) provides Ruby-language bindings for the
libcurl(3), a fully-featured client-side URL transfer library.
cURL and libcurl live at [http://curl.haxx.se/](http://curl.haxx.se/) .

Curb is a work-in-progress, and currently only supports libcurl's 'easy' and 'multi' modes.

## License

Curb is copyright (c)2006-2017 Ross Bamford & Todd Fisher, and released under the terms of the 
Ruby license. See the LICENSE file for the gory details. 

## You will need

* A working Ruby installation (1.8+, tested with 1.8.6, 1.8.7, 1.9.1, and 1.9.2)
* A working (lib)curl installation, with development stuff (7.5+, tested with 7.19.x)
* A sane build environment (e.g. gcc, make)

## Installation...

... will usually be as simple as:

    $ gem install curb

On Windows, make sure you're using the [DevKit](http://rubyinstaller.org/downloads/) and
the [development version of libcurl](http://curl.haxx.se/gknw.net/7.39.0/dist-w32/curl-7.39.0-devel-mingw32.zip). Unzip, then run this in your command
line (alter paths to your curl location, but remember to use forward slashes):

    gem install curb --platform=ruby -- --with-curl-lib=C:/curl-7.39.0-devel-mingw32/bin --with-curl-include=C:/curl-7.39.0-devel-mingw32/include

Or, if you downloaded the archive:  

    $ rake install 

If you have a weird setup, you might need extconf options. In this case, pass
them like so:

    $ rake install EXTCONF_OPTS='--with-curl-dir=/path/to/libcurl --prefix=/what/ever'
  
Curb is tested only on GNU/Linux x86 and Mac OSX - YMMV on other platforms.
If you do use another platform and experience problems, or if you can 
expand on the above instructions, please report the issue at http://github.com/taf2/curb/issues

On Ubuntu, the dependencies can be satisfied by installing the following packages:

    $ sudo apt-get install libcurl3 libcurl3-gnutls libcurl4-openssl-dev

On RedHat:

    $ sudo yum install ruby-devel libcurl-devel openssl-devel
    
Curb has fairly extensive RDoc comments in the source. You can build the
documentation with:

    $ rake doc

## Usage & examples

Curb provides two classes:

* `Curl::Easy` - simple API, for day-to-day tasks.
* `Curl::Multi` - more advanced API, for operating on multiple URLs simultaneously.

To use either, you will need to require the curb gem:

```ruby
require 'curb'
```

### Super simple API (less typing)

```ruby
http = Curl.get("http://www.google.com/")
puts http.body_str

http = Curl.post("http://www.google.com/", {:foo => "bar"})
puts http.body_str

http = Curl.get("http://www.google.com/") do|http|
  http.headers['Cookie'] = 'foo=1;bar=2'
end
puts http.body_str
```

### Simple fetch via HTTP:

```ruby
c = Curl::Easy.perform("http://www.google.co.uk")
puts c.body_str
```

Same thing, more manual:

```ruby
c = Curl::Easy.new("http://www.google.co.uk")
c.perform
puts c.body_str
```

### Additional config:

```ruby
Curl::Easy.perform("http://www.google.co.uk") do |curl| 
  curl.headers["User-Agent"] = "myapp-0.0"
  curl.verbose = true
end
```

Same thing, more manual:

```ruby
c = Curl::Easy.new("http://www.google.co.uk") do |curl| 
  curl.headers["User-Agent"] = "myapp-0.0"
  curl.verbose = true
end

c.perform
```

### HTTP basic authentication:

```ruby
c = Curl::Easy.new("http://github.com/")
c.http_auth_types = :basic
c.username = 'foo'
c.password = 'bar'
c.perform
```

### HTTP "insecure" SSL connections (like curl -k, --insecure) to avoid Curl::Err::SSLCACertificateError:

```ruby
    c = Curl::Easy.new("http://github.com/")
    c.ssl_verify_peer = false
    c.perform
```

### Supplying custom handlers:

```ruby
c = Curl::Easy.new("http://www.google.co.uk")

c.on_body { |data| print(data) }
c.on_header { |data| print(data) }

c.perform
```

### Reusing Curls:

```ruby
c = Curl::Easy.new

["http://www.google.co.uk", "http://www.ruby-lang.org/"].map do |url|
  c.url = url
  c.perform
  c.body_str
end
```

### HTTP POST form:

```ruby
c = Curl::Easy.http_post("http://my.rails.box/thing/create",
                         Curl::PostField.content('thing[name]', 'box'),
                         Curl::PostField.content('thing[type]', 'storage'))
```

### HTTP POST file upload:

```ruby
c = Curl::Easy.new("http://my.rails.box/files/upload")
c.multipart_form_post = true
c.http_post(Curl::PostField.file('thing[file]', 'myfile.rb'))
```

### Using HTTP/2

```ruby
c = Curl::Easy.new("https://http2.akamai.com")
c.set(:HTTP_VERSION, Curl::HTTP_2_0)

c.perform
puts (c.body_str.include? "You are using HTTP/2 right now!") ? "HTTP/2" : "HTTP/1.x"
```

### Multi Interface (Basic HTTP GET):

```ruby
# make multiple GET requests
easy_options = {:follow_location => true}
# Use Curl::CURLPIPE_MULTIPLEX for HTTP/2 multiplexing
multi_options = {:pipeline => Curl::CURLPIPE_HTTP1} 

Curl::Multi.get(['url1','url2','url3','url4','url5'], easy_options, multi_options) do|easy|
  # do something interesting with the easy response
  puts easy.last_effective_url
end
```

### Multi Interface (Basic HTTP POST):

```ruby
# make multiple POST requests
easy_options = {:follow_location => true, :multipart_form_post => true}
multi_options = {:pipeline => Curl::CURLPIPE_HTTP1}


url_fields = [
  { :url => 'url1', :post_fields => {'f1' => 'v1'} },
  { :url => 'url2', :post_fields => {'f1' => 'v1'} },
  { :url => 'url3', :post_fields => {'f1' => 'v1'} }
]

Curl::Multi.post(url_fields, easy_options, multi_options) do|easy|
  # do something interesting with the easy response
  puts easy.last_effective_url
end
```

### Multi Interface (Advanced):

```ruby
responses = {}
requests = ["http://www.google.co.uk/", "http://www.ruby-lang.org/"]
m = Curl::Multi.new
# add a few easy handles
requests.each do |url|
  responses[url] = ""
  c = Curl::Easy.new(url) do|curl|
    curl.follow_location = true
    curl.on_body{|data| responses[url] << data; data.size }
    curl.on_success {|easy| puts "success, add more easy handles" }
  end
  m.add(c)
end

m.perform do
  puts "idling... can do some work here"
end

requests.each do|url|
  puts responses[url]
end
```

### Easy Callbacks

* `on_success`  is called when the response code is 2xx
* `on_redirect` is called when the response code is 3xx
* `on_missing` is called when the response code is 4xx
* `on_failure` is called when the response code is 5xx
* `on_complete` is called in all cases.
