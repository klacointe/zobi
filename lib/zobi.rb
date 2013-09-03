# encoding: utf-8

require 'zobi/inherited'
require 'zobi/decorated'
require 'zobi/controlled_access'
require 'zobi/included'
require 'zobi/paginated'
require 'zobi/scoped'
require 'zobi/pagination_responder'

module Zobi
  BEHAVIORS = [:inherited, :scoped, :included, :paginated, :controlled_access, :decorated].freeze

  def behaviors *behaviors
    behaviors.each do |behavior|
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
      return resource_class if self.class.behavior_included?(:inherited)
      self.class.name.demodulize.gsub('Controller', '').singularize.constantize
    end

    def collection
      return @collection if @collection
      c = zobi_resource_class
      BEHAVIORS.each do |behavior|
        next unless self.class.behavior_included?(behavior)
        c = send :"#{behavior}_collection", c
      end
      @collection = c
    end

  end

end
