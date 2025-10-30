module AresMUSH
  module Pools
    class PoolResetCmd
      include CommandHandler
      
      attr_accessor :name

     def parse_args
        if Pools.can_manage_pools?(enactor) && (cmd.args =~ /\//)
          # Admin: <name>=<amount>/<reason>
          args = cmd.parse_args(ArgParser.arg1_equals_arg2_slash_arg3)
          self.name   = titlecase_arg(args.arg1)
          self.amount = integer_arg(args.arg2)
          self.reason = titlecase_arg(args.arg3)
        else
          # Player: <amount>=<reason> (name defaults to self)
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.name   = enactor_name
          self.amount = integer_arg(args.arg1)
          self.reason = titlecase_arg(args.arg2)
        end
      end

      def required_args
        [ self.name, self.amount, self.reason ]
      end
      
      def check_can_reset
        return nil if enactor_name == self.name
        return nil if Pools.can_manage_pools?(enactor)
        return t('dispatcher.not_allowed')
      end
    
      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          Pools.pool_reset(model, enactor, model.room)
      end
    end
  end
end
end
