# frozen_string_literal: true
#
# Site-wide noindex.
#
# al_folio_core owns the <head> (via _includes/head.liquid) and exposes no
# noindex/robots toggle, and the thin-starter style contract forbids a local
# _includes/_layouts override. So we inject the tag at build time instead: this
# runs under `bundle exec jekyll build` (the deploy workflow) and local Jekyll,
# but NOT under GitHub Pages' safe-mode build. Keep robots.txt allowing crawl so
# search engines can reach the page and see this tag.
#
# To re-enable indexing, delete this file.
Jekyll::Hooks.register [:pages, :documents], :post_render do |doc|
  next unless doc.output_ext == ".html"
  output = doc.output
  next if output.nil? || output.include?('name="robots"')

  doc.output = output.sub(%r{</head>}i, %(  <meta name="robots" content="noindex">\n</head>))
end
