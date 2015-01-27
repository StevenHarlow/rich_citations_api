Rich Citations API
==================
Live version: http://api.richcitations.org/

(c) 2014 PLOS Labs


Installing
==========
Requirements:
`Ruby 2.1.5`,`bundler`

```
$ cd rich_citations_api
$ bundle install
$ cp config/database.yml.example config/database.yml
$ bundle exec rake db:migrate
$ bundle exec rails server
```


Configurations
==============

To create a USER and API key run
rake app:user:create [name="full name"] [email=email]

