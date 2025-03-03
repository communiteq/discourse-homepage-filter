# frozen_string_literal: true

module SiteSettingsTypeSupervisorSwapdHomepageFilterExtension
  def type_hash(name)
    add_choices(name) if name == :top_menu
    super
  end

  def validate_value(name, type, val)
    add_choices(name) if name == :top_menu
    super
  end

  def add_choices(name)
    @choices[name].push("home") if @choices[name].exclude?("home")
  end
end
