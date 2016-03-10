# encoding: utf-8

module Zobi
  # This module add some helpers to controllers.
  #
  #   * inherit_resources
  #   * params filtering
  #
  module Inherited
    def self.included(klass)
      klass.send 'include', Inherited::Hidden
      klass.send 'respond_to', :html
    end

    def create
      r = zobi_resource_class.create permitted_params[zobi_resource_key]
      instance_variable_set "@#{resource_name}", r
      args = route_namespace
      args << r
      block_given? ? yield(r) : respond_with(*args)
    end
    alias_method :create!, :create

    def update
      resource.update_attributes permitted_params[zobi_resource_key]
      args = route_namespace
      args << resource
      block_given? ? yield(resource) : respond_with(*args)
    end
    alias_method :update!, :update

    def destroy
      resource.destroy
      block_given? ? yield(resource) : redirect_to(collection_path)
    end
    alias_method :destroy!, :destroy

    protected

    def resource
      r = instance_variable_get "@#{resource_name}"
      return r if r.present?
      instance_variable_set(
        "@#{resource_name}",
        (params[:id].present? ?
          resource_class.find(params[:id]) :
          resource_class.new
        )
      )
      return instance_variable_get "@#{resource_name}"
    end

    def route_namespace
      self.class.name.split('::')[0...-1].map(&:downcase)
    end

    private

    def inherited_collection c
      c
    end

    module Hidden
      protected

      # This method can be overwritted in controllers
      def permitted_params
        @permitted_params ||= parameters_class.new(self, params).params
      end

      private

      def parameters_class
        klass = "#{self.class.to_s.sub('Controller', '').singularize}Parameters"
        klass.constantize
      rescue NameError
        raise <<EOT
You need to define the class #{klass} or overwrite the permitted_params method in your controller.
EOT
      end
    end

  end
end
