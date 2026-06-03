---
layout: post
title: "Reproducing LeWM: latent rollouts, SIGReg, and where prediction drifts"
date: 2026-06-03
description: A from-scratch reproduction of LeWM, a compact latent world model, and a diagnostic study of how its predicted latent trajectories behave over long open-loop rollouts.
tags: world-models self-supervised-learning jepa rollouts
categories: research-notes
giscus_comments: false
related_posts: false
toc:
  sidebar: left
---

This is a working note, not a paper. I'm reproducing **LeWM**, a compact latent world
model, to understand a question I keep running into when I read about JEPA-style models:
*once a model learns to predict in representation space, how far can you trust those
predictions when you roll them out on their own?*

The plan for this note:

1. State what LeWM actually optimizes, in my own words, so the moving parts are explicit.
2. Describe my reproduction setup and what I checked to convince myself it was faithful.
3. Run a diagnostic on **open-loop latent rollouts** — feeding the model its own
   predictions step after step — and look at where and how the trajectory degrades.

> Status: reproduction running; the rollout diagnostic is in progress. Sections marked
> **[results pending]** are where measured numbers and plots will go once the runs settle.
> I'd rather leave them blank than fill them with placeholder numbers.

## What LeWM optimizes

A latent world model has three pieces:

- an **encoder** $f_\theta$ that maps an observation $o_t$ to a representation
  $s_t = f_\theta(o_t)$;
- a **predictor** (the dynamics model) $g_\phi$ that, given the current latent and an
  action, predicts the *next* latent: $\hat{s}_{t+1} = g_\phi(s_t, a_t)$;
- a training objective that makes $\hat{s}_{t+1}$ agree with the encoder's own
  representation of the real next frame, $s_{t+1} = f_\theta(o_{t+1})$.

The defining choice — the JEPA idea — is that the prediction target lives in
**representation space**, not pixel space. The model is never asked to reconstruct the
next frame; it is asked to predict the next *embedding*. That removes the pressure to
model every pixel of texture and lighting, and lets capacity go toward the structure that
actually predicts forward.

That choice has a well-known failure mode: **representation collapse**. If the only
objective is "make $\hat{s}_{t+1}$ close to $s_{t+1}$," the encoder can cheat by mapping
everything to a constant — then prediction is trivially perfect and the representation is
useless. The interesting part of any JEPA-style recipe is the term that prevents this.

### The SIGReg regularizer

LeWM's anti-collapse term is **SIGReg**. The core mechanism is to constrain the
*distribution* of the representation rather than only its prediction error: the encoder is
pushed toward embeddings that stay informative (spread out, non-degenerate) while the
predictor is pushed to be accurate against that moving target. So the loss splits into two
roles that pull against each other:

$$
\mathcal{L} \;=\; \underbrace{\big\lVert \hat{s}_{t+1} - \operatorname{sg}(s_{t+1}) \big\rVert^2}_{\text{prediction}} \;+\; \lambda \, \underbrace{\mathcal{R}_{\text{SIGReg}}(s)}_{\text{anti-collapse}}
$$

The prediction term wants the embeddings to be *easy to predict*; the regularizer wants
them to *remain informative*. Collapse is what you get when the first term wins outright,
so the whole game is keeping the balance, governed by $\lambda$, in a regime where the
representation stays alive.

Two things I had to get right in reproduction:

- **The stop-gradient (`sg`) on the target.** The predictor chases the encoder, not the
  other way around. Getting the gradient flow wrong here is the quiet way to either induce
  collapse or destabilize training.
- **The weight $\lambda$ on the regularizer.** Too small and the representation collapses;
  too large and prediction never gets sharp. **[results pending]** — I'm sweeping $\lambda$
  and logging a collapse diagnostic (representation variance / effective rank) alongside
  prediction loss so I can see the trade-off directly rather than inferring it.

### Action-conditioned prediction

The predictor is **action-conditioned**: $\hat{s}_{t+1} = g_\phi(s_t, a_t)$. This is what
makes it a *world* model rather than a passive video predictor — it answers "what happens
to my latent state *if I take action $a_t$*," which is exactly the query a planner or
policy needs. A clean check that conditioning is doing real work: hold $s_t$ fixed, vary
$a_t$, and confirm the predicted next latent actually moves in an action-dependent way
(rather than the predictor ignoring $a_t$ and regressing to the mean next state).
**[results pending]**

## Reproduction setup

- **Goal:** match the reported training behavior closely enough that the dynamics I study
  in the rollout section are LeWM's, not artifacts of my implementation.
- **What I reimplemented:** encoder, action-conditioned predictor, the SIGReg objective
  with stop-gradient targets, and the training loop.
- **Sanity checks before trusting anything downstream:**
  - prediction loss decreases *and* the collapse diagnostic stays healthy (the two have to
    move together — a falling loss with a collapsing representation is the trap);
  - action ablation: shuffling actions should hurt next-latent prediction;
  - one-step prediction quality is calibrated before I ever chain steps.

**[results pending]** — training curves, the collapse diagnostic over training, and the
action-ablation gap.

## The rollout diagnostic

Here's the part I actually care about. Everything above trains and evaluates the model
**one step at a time**: given a *real* $s_t$, predict $s_{t+1}$. But a world model is only
useful if you can **roll it out** — feed its own prediction back in as the next input and
keep going, with no fresh observations:

$$
\hat{s}_{t+1} = g_\phi(\hat{s}_t, a_t), \qquad \hat{s}_{t+2} = g_\phi(\hat{s}_{t+1}, a_{t+1}), \;\dots
$$

This is **open-loop** rollout, and it is strictly harder than one-step prediction, because
errors compound: every small mistake becomes the *input* to the next step, so the model is
increasingly running on states it was never trained to encounter. The question is not
*whether* it drifts but *how*: gradual blur toward the mean? a sharp break at some horizon?
collapse onto a fixed point? drift off the data manifold into nonsense?

The diagnostics I'm running:

- **Error vs. horizon.** Distance between the rolled-out latent $\hat{s}_{t+k}$ and the
  true encoded latent $s_{t+k}$, as a function of $k$. The *shape* of this curve is the
  headline result — linear creep and a sudden cliff mean very different things for
  planning. **[results pending]**
- **Where on the manifold the rollout goes.** Does $\hat{s}_{t+k}$ stay in the region of
  latent space the encoder actually produces for real frames, or does it wander off into
  states no real observation maps to? **[results pending]**
- **Action sensitivity along a rollout.** Does conditioning still steer the trajectory at
  step 20 the way it does at step 1, or does the predictor stop listening to actions once
  it's running on its own predictions? **[results pending]**

## Open questions I'm carrying

- Is the dominant failure **drift** (slow accumulation) or a **regime change** (a horizon
  past which predictions are qualitatively wrong)? The mitigation is different for each.
- How much of long-horizon stability is set by SIGReg's $\lambda$? A more strongly
  regularized representation might roll out further before drifting — or might just be
  harder to predict one step at a time. That's a measurable trade-off, not a guess.
- Does training the predictor on *its own* multi-step rollouts (rather than only one-step
  targets) buy horizon at the cost of one-step accuracy?

I'll update this note with the rollout curves as the runs finish. If you're working on
JEPA-style world models and want to compare notes, I'd genuinely like to hear from you —
the contact links are on the [about page]({{ '/' | relative_url }}).
