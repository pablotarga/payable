module Payable
  module ModelExtensions

    # Eager loading (applies to all models)
    def self.included(base)
      base.extend ClassMethods
      base.send(:include, InstanceMethods)
    end

    module ClassMethods
      def payable?; false end
      
      def payable(*args)
        
        class_eval "def self.payable?; true end"
        
        config = {:name => nil,
                  :user => :user,
                  :value => :value, 
                  :callback => nil,
                  :bill_status => :bill_status}
        config.update(args.extract_options!)

        has_many :gateway_payments, :as => :payable, :class_name => "Payable::GatewayPayment"
        has_one :gateway_payment, :as => :payable, :class_name => "Payable::GatewayPayment", :conditions => "status <> 'canceled'"
        
        state_machine config[:bill_status], :namespace => "bill", :initial => :open do
          state :open
          state :waiting
          state :payed
          state :canceled

          after_transition :on => :cancel do |payable, transition|
            payable.gateway_payment.cancel
          end

          after_transition :on => :checkout do |payable, transition|
            payable.gateway_payment.checkout        
          end

          after_transition :on => :pay do |payable, transition|
            payable.gateway_payment.pay
          end

          event :cancel do
            transition :open => :canceled
          end

          event :checkout do
            transition :open => :waiting
          end

          event :pay do
            transition [:waiting, :open] => :payed
          end
        end

        before_save :verify_gateway_payment
        define_method :verify_gateway_payment do
          self.gateway_payments.build if !self.bill_canceled? && (self.gateway_payments.size.zero? || self.gateway_payments.all?(&:canceled?))
        end
        
        define_method :payable_value do
          get_config_param(config[:value])
        end

        define_method :payable_user do
          get_config_param(config[:user])
        end

        define_method :payable_name do
          get_config_param(config[:name]) || self.class.name
        end

        define_method :payable_callback do
          get_config_param(config[:callback])
        end
        
        define_method :payable_token do
          return unless self.gateway_payment.present?
          
          self.gateway_payment.config ||= {}
          self.gateway_payment.config[:token]
        end
      end
    end

    module InstanceMethods
      def get_config_param(proc); return if proc.blank?; proc.is_a?(Proc) ? (proc.arity.zero? ? proc.call : proc.call(self)) : self.send(proc) end
      def payable?; self.class.payable? end
    end

  end
end

ActiveRecord::Base.send(:include, Payable::ModelExtensions)

