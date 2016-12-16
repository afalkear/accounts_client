# this module assumes base class has an account_name attribute.
# and thus responds to:
# - account_name
# - account_name=
# - account_name_changed?
module Accounts
  module BelongsToAccount

    def self.included(base)
      base.send(:validate, :padma_account_setted_correctly)
    end

    attr_accessor :padma_account
    ##
    # Returns associated account.
    #
    # account is stored in instance variable padma_account. This allows for it to be setted in a Mass-Load.
    #
    # @param options [Hash]
    # @option options [TrueClass] decorated          - returns decorated account
    # @option options [TrueClass] force_service_call - forces call to accounts-ws
    # @return [PadmaAccount / PadmaAccountDecorator]
    def account(options={})
      if self.padma_account.nil? || options[:force_service_call]
        self.padma_account = PadmaAccount.find_with_rails_cache(account_name)
      end
      ret = padma_account
      if options[:decorated] && padma_account
        ret = PadmaAccountDecorator.decorate(padma_account)
      end
      ret
    end

    def account_tester_level
      account.try :tester_level
    end

    private

    # If padma_account is setted with a PadmaAccount that doesn't match
    # account_id an exception will be raised
    # @raises 'This is the wrong account!'
    # @raises 'This is not a account!'
    def padma_account_setted_correctly
      # refresh_cached_account_if_needed
      return if self.padma_account.nil?
      unless padma_account.is_a?(PadmaAccount)
        raise 'This is not a account!'
      end
      if padma_account.name != self.account_name
        if self.account_name.nil?
          # if they differ because account_id is nil we set it here
          self.account_name = self.padma_account.name
        else
          raise 'This is the wrong account!'
        end
      end
    end

    def refresh_cached_account_if_needed
      if self.account_name_changed?
        self.account(force_service_call: true)
      end
    end

  end
end

