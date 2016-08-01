#!/bin/sh
rake db:migrate
foreman start -f Procfile-$AWS_ENV
