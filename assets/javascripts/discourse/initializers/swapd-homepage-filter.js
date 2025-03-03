
import { withPluginApi } from "discourse/lib/plugin-api";
import NavItem from "discourse/models/nav-item";

export default {
  name: "swapd-homepage-filter",

  initialize(container) {
    withPluginApi("1.34.0", (api) => {
      api.addNavigationBarItem({
        name: "home",
        customFilter: (category, args, router) => {
          if ((category) || (args.tagId)) {
            return false;
          }
          return true;
        },
        customHref: (category, args) => {
          return NavItem.pathFor("home", args);
        },
        before: "latest",
      });
    });
  }
}