# frozen_string_literal: true

# name: swapd-homepage-filter
# about: Filter homepage
# version: 1.0
# authors: Communiteq
# url: https://github.com/communiteq/swapd-homepage-filter

enabled_site_setting :swapd_homepage_filter_enabled

Discourse.top_menu_items.push(:home)
Discourse.anonymous_top_menu_items.push(:home)
Discourse.filters.push(:home)
Discourse.anonymous_filters.push(:home)

after_initialize do
  require_relative "config/routes.rb"
  require_relative "extend/site_settings_type_supervisor.rb"

  SiteSettings::TypeSupervisor.prepend SiteSettingsTypeSupervisorSwapdHomepageFilterExtension

  add_to_class(:topic_query, :list_home) do
    create_list(:home, {}, home_results)
  end

  add_to_class(:topic_query, :home_results) do |options = {}|
    group_ids = SiteSetting.swapd_homepage_filter_groups.gsub("|", ",")
    if group_ids != ""
      result = default_results(options)
      result = remove_muted(result, @user, options)
      result = apply_shared_drafts(result, get_category_id(options[:category]), options)
      result = result.joins("LEFT JOIN group_users gu ON gu.user_id = topics.user_id").where("gu.group_id IN (#{group_ids})")
    end
    result
  end

  add_to_class(:list_controller, :home_feed) do
    discourse_expires_in 1.minute

    options = { order: "created" }.merge(build_topic_list_options)

    @title = "#{SiteSetting.title} - #{I18n.t("rss_description.home")}"
    @link = "#{Discourse.base_url}/home"
    @atom_link = "#{Discourse.base_url}/home.rss"
    @description = I18n.t("rss_description.home")
    @topic_list = TopicQuery.new(nil, options).list_home

    render "list", formats: [:rss]
  end
end

