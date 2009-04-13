require "authlogic_rpx/version"
require "authlogic_rpx/acts_as_authentic"
require "authlogic_rpx/session"

ActiveRecord::Base.send(:include, AuthlogicRpx::ActsAsAuthentic)
Authlogic::Session::Base.send(:include, AuthlogicRpx::Session)