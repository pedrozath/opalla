module Opalla
  module ControllerAddOn
    def expose(variable_assignments)
      Opalla::Util.add_vars(variable_assignments)
      variable_assignments.each do |key, value|
        define_singleton_method(key){ value }
        self.class.helper_method key
      end
    end
  end
end