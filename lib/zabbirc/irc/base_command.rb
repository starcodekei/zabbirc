module Zabbirc
  module Irc
    HELP_FEATURES = {}
    class BaseCommand
      def self.register_help command, description
        HELP_FEATURES[command] = description
      end

      def help_features
        HELP_FEATURES
      end

      def initialize ops, message, cmd
        @ops = ops
        @message = message
        @op = get_op @message
        @cmd = cmd.strip.gsub(/\s{2,}/," ")
        @args = @cmd.split(/ /)
      end

      def run
        return unless authenticated?
        perform # perform method should be implemented in subclass
      end

      private

      def authenticated?
        @op.present?
      end

      def get_op obj
        login = get_login obj
        @ops.get login
      end

      def get_login obj
        case obj
        when Cinch::Message
          obj.user.user.sub("~","")
        when Cinch::User
          obj.user.user.sub("~","")
        when String
          obj
        else
          # Used for tests
          return obj.login if obj.respond_to? :login
          return get_login(obj.user) if obj.respond_to? :user
        end
      end

      def reply msg
        case msg
        when String
          @message.reply "#{@op.nick}: #{msg}"
        when Array
          msg.each do |m|
            reply m
          end
        end

      end
    end
  end
end
