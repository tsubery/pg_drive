# PgDrive

This library is intended to be a minimalist backup solution for Postgres, Rails and Goodle Drive. Basically a free aletrnative to [dumper](https://dumper.io).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg_drive'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pg_drive

You need to [create](https://console.developers.google.com) a new project and credential in order to use google drive. Make sure the credential is for "Oauth Client" and the application type is "Other".
Set the following environment variables:
```
ENV['PG_DRIVE_GOOGLE_KEY']="Your credential client id"
ENV['PG_DRIVE_GOOGLE_SECRET']="Your credential secret"
```
These values should be easy to find after you created new credentials in google's developer console.

After that you should run the following command inside rails console and follow the instructions.
```ruby
PgDrive.setup_credentials
```
This process is will generate a new token so the app could use a specific user's google drive account to store the backup files.

## Usage

```ruby
PgDrive.perform
```
Creates a new backup and uploads it to google drive.
You can run this command in your favorite queueing system and favorite scheduler.

## Notes
Keep in mind the backup dump and zipping are all done in memory. If your database is more than 50mb you should find a better solution.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tsubery/pg_drive.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

