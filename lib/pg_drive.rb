require "pg_drive/version"
require "google/apis/drive_v2"
require "googleauth"
require "pg_drive/uploader"
require "pg_drive/dump"

module PgDrive
  InvalidEnvironment = Class.new(StandardError)
  BackupFailed = Class.new(StandardError)

  OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
  DEFAULT_BACKUP_TIMEOUT_SECONDS = 60 * 5 # 5 minutes
  MISSING_CRED_WARNING = "Please use the run #{self}.setup_credentials"\
    " from console to set up credentials".freeze
  CREDENTIALS_INTRO = "Please open your browser and go to the following url."\
    "Login with the user you wish to use as target for backup".freeze
  CREDENTIALS_ENV_INSTRUCTIONS = "Please set the following line as the value of "\
  '"PG_DRIVE_CREDENTIALS" key in the environment hash:'.freeze

  BACKUP_CMD = "pg_dump -c -C -b".freeze
  PG_ENV_MAP = {
    "PGPASSWORD" => "password",
    "PGDATABASE" => "database",
    "PGHOST" => "host",
    "PGPORT" => "port",
    "PGUSER" => "username",
  }.freeze
  GZIP_MIME_TYPE = "application/x-gzip".freeze

  class << self
    def perform
      Uploader.call(Dump.call)
    end

    def setup_credentials
      puts CREDENTIALS_INTRO
      puts authorizer.get_authorization_url(base_url: OOB_URI)
      puts "Please enter the token you receive for further instructions"
      code = gets
      puts CREDENTIALS_ENV_INSTRUCTIONS
      puts refresh_token_from_code(code)
    end

    def authorizer
      Google::Auth::UserAuthorizer.new(
        Uploader.client_id,
        Uploader::AUTH_SCOPE,
        nil
      )
    end

    def refresh_token_from_code(code)
      authorizer.get_credentials_from_code(
        user_id: :owner,
        code: code,
        base_url: OOB_URI
      ).refresh_token
    end
  end
end
