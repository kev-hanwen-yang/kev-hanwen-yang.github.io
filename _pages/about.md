---
layout: about
title: about
permalink: /
subtitle: Independent ML researcher — self-supervised video learning, latent world models, embodied intelligence

profile:
  align: right
  image: profile_photo.png
  image_circular: false # crops the image to make it circular
  more_info: >
    <p>Melbourne, Australia</p>

selected_papers: false # includes a list of papers marked as "selected={true}"
social: true # includes social icons at the bottom of the page

announcements:
  enabled: false # includes a list of news items
  scrollable: true # adds a vertical scroll bar if there are more than 3 news items
  limit: 5 # leave blank to include all the news in the `_news` folder

latest_posts:
  enabled: true
  scrollable: true # adds a vertical scroll bar if there are more than 3 new posts items
  limit: 3 # leave blank to include all the blog posts
---

I'm an independent machine learning researcher based in Australia. My work focuses on self-supervised learning from video and latent predictive world models — JEPA-style architectures that learn to predict in representation space instead of reconstructing raw pixels. I'm interested in how these models can support embodied intelligence: agents that build a useful internal model of the world from observation alone.

Right now I'm reproducing and analyzing LeWM, a compact latent world model. I'm working through its training objective — including the SIGReg regularizer and action-conditioned latent prediction — and running a diagnostic study of how its predicted latent trajectories behave over long open-loop rollouts. I write the experiments and findings up as technical notes [on this site]({{ '/blog/' | relative_url }}).
