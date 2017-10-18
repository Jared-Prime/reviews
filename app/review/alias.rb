# frozen_string_literal: true

module Review
  class Alias
    names = YAML.load_file(ENV['USERNAME_ALIASES'])

    ALIASES = names.merge(names.invert)
                   .freeze

    CONFIG = YAML.load_file(ENV['CONFIG_FILE'])
                 .freeze

    class << self
      def for(username)
        aliasname = ALIASES.fetch(username, username)

        if silence?
          silent aliasname
        else
          aliasname
        end
      end

      def silent(aliasname)
        aliasname[0..-3] << '.' << aliasname[-2..-1]
      end

      def silence?
        too_early? || too_late?
      end

      private

      def too_late?
        current_hour > silence_start
      end

      def too_early?
        current_hour < silence_finish
      end

      def current_hour
        Time.now.utc - Time.now.beginning_of_day.utc
      end

      def silence_start
        CONFIG.dig('silence', 'start')
      end

      def silence_finish
        CONFIG.dig('silence', 'end')
      end
    end
  end
end
