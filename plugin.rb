# frozen_string_literal: true

# name: swapd-homepage-filter
# about: Filter homepage
# version: 1.0.2
# authors: Communiteq
# url: https://github.com/communiteq/swapd-homepage-filter

enabled_site_setting :swapd_homepage_filter_enabled

Discourse.top_menu_items.push(:home)
Discourse.anonymous_top_menu_items.push(:home)
Discourse.filters.push(:home)
Discourse.anonymous_filters.push(:home)

after_initialize do
  require_relative "config/routes.rb"

  # - overriding ApplicationHelper::current_homepage works as well, but bypasses the ability for a user to define their own home page
  # - we have chosen not to adjust the top_menu because that is global. By adding 'home' via addNavigationBarItem we can control that it
  #   is only added on the highest level and not on category/tab pages

  add_class_method(:site_settings, :homepage) do
    "home"
  end

  add_class_method(:site_settings, :anonymous_homepage) do
    "home"
  end

  # the following three methods are required to add a discovery route, and the _feed route in config/routes.rb

  add_to_class(:topic_query, :list_home) do
    create_list(:home, {}, home_results)
  end

  # copy of latest_results but with an additional joins/where
  add_to_class(:topic_query, :home_results) do |options = {}|
    group_ids = SiteSetting.swapd_homepage_filter_groups.gsub("|", ",")
    if group_ids != ""
      result = default_results(options)
      result = remove_muted(result, @user, options)
      result = apply_shared_drafts(result, get_category_id(options[:category]), options)
      self.class.results_filter_callbacks.each do |filter_callback|
        # call it with :latest so we don't need to modify the discourse-suppress-category-from-latest plugin
        result = filter_callback.call(:latest, result, @user, options)
      end
      result = result.joins("LEFT JOIN group_users gu ON gu.user_id = topics.user_id").where("gu.group_id IN (#{group_ids})")
    end
    result
  end

  # just a copy from latest_feed
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

