require 'diffDOM.js'

module Opalla
  class DiffDom
    def initialize(after_apply: ->{})
      @instance = %x{new diffDOM({
        valueDiffing: false
      })}
      # {
      #   postDiffApply: function(info){
      #     if('e' in info.diff){
      #       #{after_apply.call(Element[`info.node`])}
      #     }
      #   }
      # })}
    end

    def diff(a,b)
      %x{#{@instance}.diff(#{a}[0], #{b}[0])}
    end

    def apply(el, diff)
      %x{#{@instance}.apply(#{el}[0], #{diff})}
    end
  end
end