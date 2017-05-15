class Element
  def morph(target, callback=nil)
    dd     = Opalla::DiffDom.new(after_apply: callback)
    diff   = dd.diff(self, target)
    dd.apply(self, diff)
    self
  end

  def inner_html
    `#{self}[0].innerHTML`
  end

  def outer_html
    `#{self}[0].outerHTML`
  end

end