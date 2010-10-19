module ARSettings
  def self.settings_class=(classname)
    Object.const_set classname , 3
  end
end
