#!/bin/bash

bundle exec rflow load -c config.rb
bundle exec rflow start -d config.sqlite -g rflow-components-http -g rflow-components-file -e extensions.rb 
