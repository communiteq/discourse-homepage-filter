Discourse::Application.routes.append do
  get 'home_feed' => 'list#home_feed', :format => :rss
end
