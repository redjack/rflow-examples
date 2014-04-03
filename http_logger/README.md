# HTTP Logger

A simple workflow that sets up an HTTP server that responds to
incoming requests and also saves the request and resulting response to
a file.

Uses components in
[`rflow-components-http`](http://github.com/redjack/rflow-components-http)
and
[`rflow-components-file`](http://github.com/redjack/rflow-components-file)
gems to provide standard components for HTTP
(`RFlow::Components::HTTP::Server`) and file
(`RFlow::Components::File::OutputRawToFiles`) handling. Also defines
two additional components in [extensions.rb](extensions.rb):

* `RFlow::Components::HTTPResponder` - sends a HTTP response for each
  HTTP request recieved.  Note that RFlow message provenance is
  required for the HTTP server to know what response should be matched
  to a given request, so the component copies the request provenance
  to the response provenance.

* `RFlow::Components::HTTPToRaw` - transforms HTTP messages to raw
  messages to be output by the raw file output component.

The workflow definition file ([`config.rb`](config.rb)) sets up the
initial HTTP request/response workflow using the HTTP server and HTTP
responder components to respond to any HTTP request. It also connects
to the output ports on the HTTP server (the HTTP request) and the HTTP
responder (the HTTP response), effectively duplicating the messages to
the raw transformer and ultimately writing them to individual files.

To run the workflow, first make sure you have dependencies installed:

```shell
bundle install
```

Then generate the sqlite configuration database (which will by default
be named config.sqlite, but can be changed with the `-d` flag):

```shell
bundle exec rflow load -c config.rb
```

And then start the server running:

```shell
bundle exec rflow start -d config.sqlite -g rflow-components-http -g rflow-components-file -e extensions.rb
```

Note that the above `rflow start` command loads the http and file
component gems from the command line using the `-g` flag, and alos loads
loads the local `extensions.rb`.  Alternatively , the http and file
component gems could be `require`d in the `extensions.rb` file and the
arguments removed from the command line.  Also, since `config.sqlite`
is the default name for the config database, we can simplify the
command line to the following:

```shell
bundle exec rflow start -e extensions.rb
```
