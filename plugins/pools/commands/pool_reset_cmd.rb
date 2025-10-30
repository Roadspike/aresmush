module AresMUSH
  module Pools
    class PoolResetCmd
      include CommandHandler
      
      # Multiple targets allowed for admins.
      attr_accessor :targets, :reason

      def parse_args
        if Pools.can_manage_pools?(enactor) && (cmd.args =~ /\//)
          # Admin: <name[, name ...]>/<reason>
          args = cmd.parse_args(ArgParser.arg1_slash_arg2)
          raw_names  = args.arg1 || ""
          self.reason = titlecase_arg(args.arg2)
          # Split on commas OR whitespace, drop blanks, titlecase each
          self.targets = raw_names.split(/[,\s]+/)
                                  .map { |n| n.strip }
                                  .reject { |n| n.empty? }
                                  .map { |n| titlecase_arg(n) }
        else
          # Player: <reason> (defaults to self)
          self.targets = [ enactor_name ]
          self.reason  = titlecase_arg(cmd.args)
        end
      end

      def required_args
        [ self.targets, self.reason ]
      end

      def check_can_reset
        # Allow if it's only self
        only_self = self.targets.length == 1 && self.targets.first&.downcase == enactor_name&.downcase
        return nil if only_self
        # Otherwise require manage_pools
        return nil if Pools.can_manage_pools?(enactor)
        return t('dispatcher.not_allowed')
      end

      def handle
        # De-dup just in case
        names = self.targets.uniq
        successes = []
        failures  = []

        names.each do |target_name|
          ClassTargetFinder.with_a_character(target_name, client, enactor) do |model|
            begin
              Pools.pool_reset(model, enactor, model.room)
              Global.logger.info "Pool Reset by #{enactor.name} for #{model.name}: #{self.reason}"
              successes << model.name
            rescue => ex
              Global.logger.warn "Pool reset failed for #{target_name}: #{ex}"
              failures << target_name
            end
          end
        end

        # Optional client summary (the room/scene already saw messages from pool_reset)
        if successes.any?
          client.emit_success "Reset pools for: #{successes.join(', ')}."
        end
        if failures.any?
          client.emit_failure "Couldn’t find or reset: #{failures.join(', ')}."
        end
      end
    end
  end
end
