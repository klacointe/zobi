# encoding: utf-8

Dir["#{File.dirname(__FILE__)}/zobi/**/*.rb"].each { |f| require f }

module Zobi
  BEHAVIORS = [:inherited, :scoped, :included, :paginated, :controlled_access, :decorated].freeze

  def self.extended base
    base.helper_method :collection, :resource, :resource_class,
      :collection_path, :new_resource_path, :edit_resource_path, :resource_path
  end

  def behaviors *behaviors
    (BEHAVIORS & behaviors).each do |behavior|
      send(:include, behavior_module(behavior))
    end
    send(:include, ::Zobi::InstanceMethods)
  end

  def behavior_module name
    "Zobi::#{name.to_s.camelize}".constantize
  end

  def behavior_included? name
    ancestors.include?(behavior_module(name))
  end

  module InstanceMethods

    def zobi_resource_class
      @_zobi_resource_class ||= zobi_resource_name.classify.constantize
    end
    alias_method :resource_class, :zobi_resource_class

    def zobi_resource_name
      @_zobi_resource_name ||= self.class.to_s.demodulize.gsub(/Controller$/, '').singularize
    end
    alias_method :resource_name, :zobi_resource_name

    def zobi_resource_key
      @_zobi_resource_key ||= zobi_resource_name.underscore
    end
    alias_method :resource_key, :zobi_resource_key

    def collection
      return @collection if @collection
      c = zobi_resource_class
      BEHAVIORS.each do |behavior|
        next unless self.class.behavior_included?(behavior)
        c = send :"#{behavior}_collection", c
      end
      @collection = (c.is_a?(Class) ? c.all : c)
    end

    def collection_path
      url_for controller: zobi_resource_key.pluralize, action: :index
    end

    def new_resource_path
      url_for controller: zobi_resource_key.pluralize, action: :new
    end

    def edit_resource_path r
      url_for controller: zobi_resource_key.pluralize, action: :edit, id: r.id
    end

    def resource_path r
      url_for controller: zobi_resource_key.pluralize, action: :show, id: r.id
    end
  end
end
