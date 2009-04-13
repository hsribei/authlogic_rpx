module AuthlogicRpx
  # This module is responsible for adding all of the RPX goodness to the Authlogic::Session::Base class.
  module Session
    # Add a simple rpx_identifier attribute and some validations for the field.
    def self.included(klass)
      klass.class_eval do
        extend Config
        include Methods

      end
    end
    
    module Config
      
      def find_by_rpx_identifier_method(value = nil)
        config(:find_by_rpx_identifier_method, value, :find_by_rpx_identifier)
      end
      alias_method :find_by_rpx_identifier_method=, :find_by_rpx_identifier_method
      
    end
    
    module Methods
      
      def self.included(klass)
        klass.class_eval do
          attr_accessor :rpx_identifier
          attr_accessor :rpx_data

          validate :validate_by_rpx, :if => :authenticating_with_rpx?
        end
      end
      
    # Hooks into credentials so that you can pass an :rpx_identifier key.
    def credentials=(value)
      super
      values = value.is_a?(Array) ? value : [value]
      hash = values.first.is_a?(Hash) ? values.first.with_indifferent_access : nil
      self.rpx_identifier = hash[:rpx_identifier] if !hash.nil? && hash.key?(:rpx_identifier)
      self.rpx_data = hash[:rpx_data] if !hash.nil? && hash.key?(:rpx_data)
    end
  
    private
      def authenticating_with_rpx?
        controller.params[:token]
      end

      def find_by_openid_identifier_method
        self.class.find_by_rpx_identifier_method
      end
    
      def validate_by_rpx
        @rpx_data = RPXNow.user_data(controller.params[:token]) {|raw|
          user_data = {}
          user_data[:rpx_identifier] = raw['profile']['identifier']
          user_data[:provider_name] = raw['profile']['providerName']
          
          user_data[:email] = raw['profile']['verifiedEmail']
          user_data[:name] = raw['profile']['displayName']
          
          user_data[:id] = raw['profile']['primaryKey'].to_i if raw['profile']['primaryKey']
          user_data
        }
        
        # Cancelled signin?
        if @rpx_data.nil?
          errors.add_to_base("An error occurred. Please try again.")
          return
        end

        self.attempted_record = klass.find_by_rpx_identifier(@rpx_data[:rpx_identifier])
        
        
        
        if !attempted_record
          errors.add_to_base("We did not find any accounts with that login. Enter your details and create an account.")
          return
        end
        
        
      end
      
      def map_rpx_registration
        
      end
      
    
    end
    
  end
end