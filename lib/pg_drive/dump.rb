module PgDrive
  module Dump
    class << self
      def call
        stdin, out_and_error, wait_thr = exec_pg_dump
        read_with_timeout(out_and_error, wait_thr)
      ensure
        stdin&.close
        out_and_error&.close
      end

      def read_with_timeout(input, wait_thr)
        result = Timeout.timeout(backup_timeout_seconds) { input.read }

        unless wait_thr.value.success? || result.blank?
          raise BackupFailed, "Exit status: #{wait_thr.value.exitstatus}: #{result}"
        end
        result
      rescue Timeout::Error
        if (kill_pid = wait_thr[:pid])
          Process.kill(9, Process.getpgid(kill_pid))
        end
        raise BackupFailed, "Timeout error for backup_command #{kill_pid}"
      end

      def exec_pg_dump
        Open3.popen2e(
          pg_env,
          BACKUP_CMD,
          pgroup: true
        )
      end

      def pg_env
        PG_ENV_MAP.map { |k, v| [k, db_conf[v].to_s] }.to_h
      end

      def db_conf
        @db_conf ||= Rails.configuration.database_configuration[Rails.env]
      end

      def backup_timeout_seconds
        DEFAULT_BACKUP_TIMEOUT_SECONDS
      end
    end
  end
end
