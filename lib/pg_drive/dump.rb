module PgDrive
  module Dump
    class << self
      def call
        stdin, stdout, stderr, wait_thr = Open3.popen3(
          pg_env,
          BACKUP_CMD,
          pgroup: true
        )

        tmpfile = Tempfile.new("pg_backup")
        tmpfile.write(stdout)
        tmpfile.rewind

        errors = stderr.read
        unless wait_thr.value.success? && errors.empty?
          raise BackupFailed, "Exit status: #{wait_thr.value.exitstatus}: #{errors}"
        end

        yield tmpfile
      ensure
        [stdin, stdout, stderr, tmpfile].compact.each(&:close)
      end

      def pg_env
        PG_ENV_MAP.map { |k, v| [k, db_conf[v].to_s] }.to_h
      end

      def db_conf
        @db_conf ||= Rails.configuration.database_configuration[Rails.env]
      end
    end
  end
end
