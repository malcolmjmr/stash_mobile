

import 'package:stashmobile/models/domain.dart';

List<Domain> defaultDomains = [
  Domain(
      url: 'www.google.com',
      searchTemplate: 'https://www.google.com/search?q=<|search|>',
      title: 'Google',
      favIconUrl: 'https://www.google.com/images/branding/product/1x/gsa_android_144dp.png'
    ),
    Domain(
      title: 'Bing',
      url: 'https://www.bing.com',
      favIconUrl: 'https://www.bing.com/sa/simg/favicon-trans-bg-blue-mg.ico',
      searchTemplate: "https://www.bing.com/search?q=<|search|>",
    ),
    Domain(
      title: 'DuckDuckGo',
      url: 'https://duckduckgo.com',
      favIconUrl: 'https://duckduckgo.com/favicon.ico',
      searchTemplate: 'https://duckduckgo.com/?q=<|search|>',
    ),
    Domain(
      title: 'Sublime',
      url: 'https://sublime.app',
      searchTemplate: 'https://sublime.app/search?query=<|search|>',
      favIconUrl: 'https://sublime.app/apple-touch-icon.png',
    ),
    Domain(
      title: 'Twitter',
      url: 'https://twitter.com',
      favIconUrl: 'https://abs.twimg.com/favicons/twitter.3.ico',
      searchTemplate: 'https://twitter.com/search?q=<|search|>',
    ),
    Domain(
      title: 'Reddit',
      url: 'https://www.reddit.com',
      favIconUrl: 'https://www.redditstatic.com/shreddit/assets/favicon/64x64.png',
      searchTemplate: 'https://www.reddit.com/search/?q=<|search|>'
    ),
    Domain(
      title: 'Youtube',
      url: 'https://youtube.com',
      favIconUrl: "https://www.youtube.com/s/desktop/7ea5dfab/img/favicon_32x32.png",
      searchTemplate: 'https://www.youtube.com/results?search_query=<|search|>',
    ),
    Domain(
      title: 'Hypothesis',
      url: 'https://hypothes.is',
      searchTemplate: 'https://hypothes.is/search?q=<|search|>',
      favIconUrl: 'https://hypothes.is/assets/images/favicons/favicon-32x32.png?07d072'
    ),
    Domain(
      title: 'Amazon',
      url: 'amazon.com',
      favIconUrl: 'https://www.amazon.com/favicon.ico',
      searchTemplate: 'https://www.amazon.com/s?k=<|search|>'
    ),
    Domain(
      title: 'Substack',
      url: 'https://substack.com',
      searchTemplate: 'https://substack.com/search/<|search|>',
      favIconUrl: 'https://substackcdn.com/icons/substack/favicon.ico',
    ),
    Domain(
      title: 'New York Public Library',
      url: 'https://www.nypl.org',
      favIconUrl: 'https://ux-static.nypl.org/images/favicon.ico',
      searchTemplate: 'https://nypl.na2.iiivega.com/search?query=<|search|>&searchType=everything&pageSize=10'
    ),
    Domain(
      title: 'Notion',
      url: 'https://www.notion.so',
      favIconUrl: 'https://www.notion.so/images/favicon.ico'
    ),
    Domain(
      title: 'Quora',
      url: 'https://www.quora.com',
      favIconUrl: 'https://qsf.fs.quoracdn.net/-4-ans_frontend_assets.favicon-new-badged.ico-26-7a2cda9b4acdaf19.ico',
      searchTemplate: 'https://www.quora.com/search?q=<|search|>',
    ),
    Domain(
      title: 'Hacker News',
      url: 'https://news.ycombinator.com',
      searchTemplate: 'https://hn.algolia.com/?q=<|search|>',
      favIconUrl: 'https://news.ycombinator.com/favicon.ico'
    ),
    Domain(
      title: 'Sci Hub',
      favIconUrl: 'https://sci-hub.hkvisa.net/favicon.ico',
      url: 'https://sci-hub.hkvisa.net'
    )
  ];