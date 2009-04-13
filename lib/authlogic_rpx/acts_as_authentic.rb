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