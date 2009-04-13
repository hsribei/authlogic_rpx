# This module is responsible for adding RPX functionality to Authlogic. Checkout the README for more info and please
# see the sub modules for detailed documentation.
module AuthlogicRpx
  # This module is responsible for adding in the RPX functionality to your models. It hooks itself into the
  # acts_as_authentic method provided by Authlogic.
  module ActsAsAuthentic
    # Adds in the neccesary modules for acts_as_authentic to include and also disabled password validation if
    # RPX is being used.
    def self.included(klass)
      klass.class_eval do
        add_acts_as_authentic_module(Methods, :prepend)
      end
    end
    
    module Methods
      # Set up some simple validations
      def self.included(klass)
        klass.class_eval do
          validates_uniqueness_of :rpx_identifier, :scope => validations_scope, :if => :using_rpx?
          
          validates_length_of_password_field_options validates_length_of_password_field_options.merge(:if => :validate_password_with_rpx?)
          validates_confirmation_of_password_field_options validates_confirmation_of_password_field_options.merge(:if => :validate_password_with_rpx?)
          validates_length_of_password_confirmation_field_options validates_length_of_password_confirmation_field_options.merge(:if => :validate_password_with_rpx?)
          
          after_create :map_rpx_identifier
        end
      end
      
      # This is where all of the magic happens. This is where we hook in and add all of the RPX sweetness.
      #
      # I had to take this approach because when authenticating with RPX nonces and what not are stored in database
      # tables. That being said, the whole save process for ActiveRecord is wrapped in a transaction. Trying to authenticate
      # with OpenID in a transaction is not good because that transaction be get rolled back, thus reversing all of the OpenID
      # inserts and making OpenID authentication fail every time. So We need to step outside of the transaction and do our OpenID
      # madness.
      #
      # Another advantage of taking this approach is that we can set fields from their OpenID profile before we save the record,
      # if their OpenID provider supports it.
      # def save(perform_validation = true, &block)
      #   if !perform_validation || !authenticate_with_rpx? || (authenticate_with_rpx? && authenticate_with_rpx)
      #     result = super
      #     yield(result) if block_given?
      #     result
      #   else
      #     false
      #   end
      # end
      
      private
        
        def using_rpx?
          !rpx_identifier.blank?
        end
        
        def validate_password_with_rpx?
          !using_rpx? && require_password?
        end
        
        def map_rpx_identifier
          RPXNow.map(rpx_identifier, id) if using_rpx?
        end
        
        def unmap_rpx_identifer
          RPXNow.unmap(rpx_identifier, id) if using_rpx?
        end
        
    end
  end
end