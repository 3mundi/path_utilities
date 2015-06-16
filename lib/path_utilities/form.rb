require 'active_support/concern'
require 'active_support/inflector'
require 'active_model/naming'
require 'active_model/conversion'
require 'active_model/validations'

module PathUtilities
  module Form
    extend ActiveSupport::Concern

    autoload :UniquenessValidator, 'path_utilities/form/uniqueness_validator'
    autoload :TrackingChanges, 'path_utilities/form/tracking_changes'

    included do
      include Virtus.model
      extend ActiveModel::Naming
      include ActiveModel::Conversion
      include ActiveModel::Validations
      include TrackingChanges

      attr_reader :models_mapping

      delegate :id, :persisted?, :new_record?, to: :main_record

      def initialize(models_mapping = {})
        @models_mapping = models_mapping
        validate_mapping!
        init_sync
      end

      def validate_mapping!
        self.class.models.each do |model|
          next if models_mapping.keys.include?(model)
          fail "#{model.to_s.camelize} not mapped on initialization"
        end
      end

      def validate(params)
        params = HashWithIndifferentAccess.new(params)
        self.class.fields.keys.each do |field|
          any_changes = params[field] &&
                        params[field] != instance_model_for(field).send(field)
          next unless any_changes
          send("#{field}=", params[field])
        end

        valid?
      end

      def save
        if valid?
          sync
          persist!
          true
        else
          false
        end
      end

      def sync
        self.class.fields.keys.each do |field|
          form_field_value = send(field)
          instance_model_for(field).send("#{field}=", form_field_value)
        end
      end

      def instance_model_for(field)
        model = self.class.fields[field].options[:klass].name.underscore.to_sym
        models_mapping[model]
      end

      def init_sync
        self.class.fields.keys.each do |field|
          model_value = instance_model_for(field).send("#{field}")
          send("#{field}=", model_value)
        end
      end

      def main_record
        models_mapping[self.class.model_name.name.to_sym]
      end

      def persist!
        models_mapping.values.all?(&:save)
      end
      private :persist!
    end

    class_methods do
      def properties(attributes, model)
        @@attributes ||= {}
        add_model(model)
        attributes.each do |att|
          already_define_attribute_warn(att, model) do
            attribute att, String
          end

          @@attributes[att] = model.to_s.camelize
                                  .safe_constantize.fields[att.to_s]
        end
      end

      def setup_model_name(name)
        @@model_name = ActiveModel::Name.new(self, nil, name.to_s)
      end

      def model_name
        @@model_name || fail('setup_model_name not set in form class')
      end

      def fields
        @@attributes
      end

      def already_define_attribute_warn(attr, new_model)
        if fields[attr].nil?
          yield
        else
          Rails.logger.warn "#{attr} param already defined " \
                            "for #{fields[attr]} model"

          return unless fields[attr] != new_model
          Rails.logger.warn "#{attr} now is mapped to #{new_model}"
        end
      end

      def models
        @@models ||= []
      end

      def add_model(name)
        models
        return if models.include?(name.to_sym)
        @@models << name.to_sym
      end

      def validates_uniqueness_of(attribute, options = {})
        options = { case_sensitive: false, attributes: [attribute],
                    model: model_for(attribute) }
                  .reverse_merge(options)
        validates_with(validation_class_for(attribute), options)
      end

      def validation_class_for(attr)
        model_klass = model_for(attr)
        case
        when model_klass.ancestors.include?(::Mongoid::Document)
          'PathUtilities::Form::UniquenessValidator::Mongoid'
        else
          fail "#{model_klass.name} is not currently supported"
        end.safe_constantize
      end

      def model_for(attr)
        fields[attr] && fields[attr].options[:klass]
      end

      # mongoid-encrypted-fields gem compatibility method
      def database_field_name(attribute)
        attribute.to_sym
      end
    end
  end
end
