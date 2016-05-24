module PgDrive
  module Uploader
    Drive = Google::Apis::DriveV2
    AUTH_SCOPE = "https://www.googleapis.com/auth/drive".freeze
    RETRY_COUNT = 3

    class << self
      def call(content)
        drive = Drive::DriveService.new
        drive.authorization = credentials
        app_name = Rails.application.class.parent_name
        drive.insert_file(
          Drive::File.new(title: "#{app_name}-#{Time.now.utc.iso8601}.dmp"),
          upload_source: StringIO.new(content),
          content_type: BINARY_MIME_TYPE,
          options: { retries: RETRY_COUNT }
        )
      end

      def client_id
        Google::Auth::ClientId.new(google_key, google_secret)
      end

      def google_key
        ENV.fetch("PG_DRIVE_GOOGLE_KEY")
      end

      def google_secret
        ENV.fetch("PG_DRIVE_GOOGLE_SECRET")
      end

      def credentials
        refresh_token = ENV["PG_DRIVE_CREDENTIALS"]
        if refresh_token.nil? || refresh_token.empty?
          raise InvalidEnvironment, MISSING_CRED_WARNING
        end
        Google::Auth::UserRefreshCredentials.new(
          client_id: google_key,
          client_secret: google_secret,
          refresh_token: refresh_token,
          scope: AUTH_SCOPE
        )
      end
    end
  end
end
