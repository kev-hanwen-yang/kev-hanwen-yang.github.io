---
layout: about
title: about
permalink: /
subtitle:

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
I'm an independent ML researcher and incoming graduate research candidate at Australian Institute for Machine Learning (AIML), working on self-supervised representation learning, world models and how they can support embodied agents that build an internal model of the world from observation and action.

**Recent work: [Long-Horizon Rollout Diagnostics for Latent World Models: LeWM on Push-T](https://kev-hanwen-yang.github.io/blog/2026/lewm-latent-dynamics/)**

I reproduced LeWM, a compact JEPA-style latent world model (SIGReg-regularised,
action-conditioned latent prediction), and asked whether its stable-looking
predicted latents actually preserve action-relevant physical state over long
open-loop rollouts. Using probe-based state recovery, latent-space geometric
diagnostics, and a teacher-forced control, I traced the dominant failure to
under-amplification already present in the one-step transition map rather than
compounding rollout feedback — a result that revised my initial hypothesis.

→ Code and reproduction notes: [kev-hanwen-yang/le-wm](https://github.com/kev-hanwen-yang/le-wm)

**Also:** [RVSS Need4Speed](https://github.com/kev-hanwen-yang/RVSS-competition) —
CNN-based imitation learning for an autonomous driving competition: data
collection, training, on-robot deployment and debugging under real hardware
constraints.

Background: software engineer building production data infrastructure at scale,
before moving to ML research full-time.

Especially interested in self-supervised video representations, action-conditioned
latent dynamics, and world models that support long-horizon prediction and
planning in embodied agents.

Reach me: kevin.yang0047@gmail.com
