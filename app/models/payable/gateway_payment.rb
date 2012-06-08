# coding: utf-8
module Payable
  class GatewayPayment < ActiveRecord::Base
    attr_accessible :payable_type, :payable_id, :config
    serialize :config

    state_machine :status, :initial => :open do
      state :open
      state :waiting
      state :payed
      state :canceled

      after_transition :on => :pay do |gate, transition|
        return unless gate.payable.present?
        gate.payable.pay_bill
        gate.payable.try(:payable_callback)
      end

      after_transition :on => :cancel do |gate, transition|
        gateway_payment = gate.payable.try(:verify_gateway_payment)
        gateway_payment.save if gateway_payment.present?
      end

      before_transition :on => :checkout do |gate, transition|
        gate.payable_checkout
        
        if gate.config[:response]["Status"] == "Sucesso"
          gate.config.delete(:response).each { |k,v| gate.config[k.to_s.downcase] = v }
          gate.config.symbolize_keys!
        else
          #TODO: Como tratar esta exception handling
          raise "Erro no envio da requisição: #{gate.config[:response]['Erro']['__content__']}"
        end
      end

      after_transition :on => :checkout do |gate, transition|
        gate.payable.try(:checkout_bill)
        gate.update_attribute :expires_at, 15.minutes.from_now
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

    scope :active, :conditions => "status <> 'canceled'", :limit => 1

    belongs_to :payable, :polymorphic => true

    before_validation :ensure_config_is_a_hash
    def ensure_config_is_a_hash
      self.config = {} unless self.config.is_a?(Hash)
    end

    def payable_checkout
      builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
        # Identificador do tipo de instrução
        xml.EnviarInstrucao {
          xml.InstrucaoUnica(:TipoValidacao => "Transparente") {
            xml.Razao{xml.text "Pagamento #{payable.payable_name} ##{self.id}"}
            xml.Valores{
              xml.Valor(:moeda => "BRL"){ xml.text payable.payable_value.to_f }
            }
            xml.IdProprio{ xml.text "#{('aa'..'zz').to_a.sample}-#{self.id}-#{rand(1000)}" }

            #dados do pagador
            xml.Pagador{
              xml.IdPagador { xml.text payable.payable_user.id }
              xml.Nome      { xml.text payable.payable_user.name }
              xml.Email     { xml.text payable.payable_user.email }
              xml.EnderecoCobranca {
                addr = payable.payable_user.billing_address
                xml.Logradouro  { xml.text addr.address}
                xml.Numero      { xml.text addr.number}
                xml.Complemento { xml.text addr.complement}
                xml.Bairro      { xml.text addr.district}
                xml.Cidade      { xml.text addr.city_name}
                xml.Estado      { xml.text addr.state_name}
                xml.Pais        { xml.text addr.country_name}
                xml.CEP         { xml.text addr.zip}
                xml.TelefoneFixo{ xml.text addr.phone}
              }
            }

            #dados do parcelamento
            xml.Parcelamentos{
              xml.Parcelamento{
                xml.MinimoParcelas{ xml.text 2}
                xml.MaximoParcelas{ xml.text 99}
                xml.Repassar{ xml.text 'true' }
              }
            }

            #dados de comissões
          }
        }
      end

      response = HTTParty.post('https://desenvolvedor.moip.com.br/sandbox/ws/alpha/EnviarInstrucao/Unica', 
                                :body => builder.to_xml,
                                :basic_auth => {:username => 'E6T1EBOPOMQ62CXJI4PGKPETAPROIEJD', 
                                                :password => 'FELWDIWMPL7QPFABGZHH0OFF24BGL2ZGDSDYCS3A'}).parsed_response
      self.config ||= {}
      self.config[:response] = response["EnviarInstrucaoUnicaResponse"]["Resposta"]
    end
  end
end
