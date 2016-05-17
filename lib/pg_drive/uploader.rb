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
          Drive::File.new(title: "backup-#{app_name}-#{Time.now.to_i}"),
          upload_source: gzip(content),
          content_type: GZIP_MIME_TYPE,
          options: { retries: RETRY_COUNT }
        )
      end

      def gzip(string)
        gzipped_io = StringIO.new
        writer = Zlib::GzipWriter.new(gzipped_io)
        writer.write(string)
        writer.close
        StringIO.new(gzipped_io.string)
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
