# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

3.0.3 - at press time, the latest Rails version 7 was not ready to run on Ruby
3.1.0 yet, so I used the next to latest version instead, which is 3.0.3 today.

To work with GitHub Actions as I have it configured, you should set up a
[self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners)
with Linux as an OS. Here's mine:

```
$ uname -a
Linux msigaming 5.15.0-2-amd64 #1 SMP Debian 5.15.5-2 (2021-12-18) x86_64 GNU/Linux
```

Add a self-hosted runner to your repo at the link like (replace with your user):

[kingdonb/scrob-web/settings/actions/runners](https://github.com/kingdonb/scrob-web/settings/actions/runners)

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
encrypted creds. There is nothing important in the encrypted file now, as the
e-mail is not used for anything at all.

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

... the database has not been changed from the default sqlite3

You may want to consider doing that, if the database records need to be kept.

* How to run the test suite

`bundle exec rspec`

* Services (job queues, cache servers, search engines, etc.)

There are no external services besides Google Spreadsheets and Google Auth

The only job queue is the GitHub Actions Runner, which I have configured as
adjacent to my staging cluster, `moo-cluster` in [bootstrap-repo][]

Note this is not configured using Kubernetes, only the instructions from GitHub

![msigaming3 the Self-Hosted Runner](/kingdonb/scrob-web/raw/main/assets/images/hosted-runner-msigaming3.png)

* Deployment instructions

First run ./builder.sh and then deploy from manifests/k8s.yml

This may not succeed if there are no images because you've just started. In that case,
make sure you have these variables in your env:

```
MINIO_ACCESS_KEY=8TZRY2JRW.....
MINIO_SECRET_KEY=gbstrOvot.....
HARBOR_BOT_USER=robot$scrob+scrob-bot
HARBOR_BOT_PASSWORD=HBjXvtvfJn9CGLYNp..............
RAILS_MASTER_KEY=ich8Quieyooghiephii2aefeecba7e51
```

You will need your own minio/harbor for this, or a different S3/img host. Set
up your own configuration `kuby.rb` to match it as well. This will result in a
new manifest/k8s.yml if you run the `builder.rb` again. Good luck!

* ...

I built this to minimize outside network and to reuse the same builder from one
job to the next, which saves a lot on cache fetches as the cache always tends
to be fresh, it usually does not need any fetch at all.

I had problems getting the right bundler version until after I remembered to
run `gem update --system` on the actions runner host. Make sure you remember to
install the right version of Ruby as well (eg. `rvm install 3.0.3`)

Any questions? Reach kingdonb at #flux on the [CNCF Slack][flux-on-cncf-slack]

[bootstrap-repo]: https://github.com/kingdonb/bootstrap-repo/tree/staging
[flux-on-cncf-slack]: https://cloud-native.slack.com/channels/flux
