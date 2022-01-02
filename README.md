# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

3.0.3 - at press time, the latest Rails version 7 was not ready to run on Ruby
3.1.0 yet, so I used the next to latest version instead.

* System dependencies

from `.prebundle_config`:

`MINIO_ACCESS_KEY`
`MINIO_SECRET_KEY`

should have access to a bucket `scrob-web` on S3 endpoint:
`https://minio.hephy.pro` `  # or whatever`...

Change this in the prebundler config file if you are not from the domain
`hephy.pro`.  You can use any S3 provider, or set up Minio as I have done!

from `kuby.rb`:

`KUBY_DOCKER_EMAIL` is the only credential that is stored in the Rails
encrypted credentials file `credentials.yml.enc`, if you prefer not to store
anything in the encrypted credentials file, then you can disable Rails
encrypted creds. There is nothing important in the encrypted file now.

You should set these environment variables in your CI system:

```ruby
docker do
  credentials do
    username ENV['HARBOR_BOT_USER']
    password ENV['HARBOR_BOT_PASSWORD']
  end
```

Set these to your container image bot credential and update `image_url` so it reflects your own account and whatever `scrob/web` you decided to use instead of mine:

```ruby
  image_url 'img.hephy.pro/scrob/web'
end
```

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
