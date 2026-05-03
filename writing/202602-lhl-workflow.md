I've been closely tracking AI-assisted coding since the ChatGPT launch. My goal is to have an eye on the bleeding edge, but to not be caught up chasing every new thing. There's a lot of churn and FOMO in the space, but things also get "baked-in" very quickly, and it's important to remember, the point is to save time and effort. My goal is Pareto efficiency: see what is boiled-down post-hype, adopt what gives the best gains for my actual work (vs yak-shaving).

## Big Picture

Opus 4.5 and GPT 5.2 were the biggest gamechangers for me and since their release, now do 99% of my code-writing. Before that, I was mostly still going through most of my code (e.g., except for one-off scripts I didn't care about), but I've now switched mainly to enforcing quality through specs and test coverage even for long-lived projects (the latest models can spelunk and parse code better than I can).

## My Current Setup

This is in a state of flux as new scaffolding comes out and I've been poking at new scaffolds and control planes, and I fully expect my setup to look quite different in 6 months, but my main setup currently is `byobu` with aggressive `F8` pane labeling:

- One byobu session per project
- Instead of subagents/swarms, I aggressively create new panes anytime I need
- Every pane gets descriptively named (e.g., coder-5.3, planner-claude, etc.)
- I tend to use a single main coder per worktree but have multiple planners or reviewers

I mostly use Codex and Claude Code, but use some Amp and OpenCode as well. I've tried some mobile/web prompting flows (Happy, etc) but generally byobu (tmux) via Tailscale is how I manage everything. This lets me run my agents and access them remotely when I want, and is an easy adaptation of the same sort of workflow I've used for years (but with AI agents coding).

My general preference is to run the strongest models available. As of my latest testing, GPT-5.3 Codex xhigh is the strongest general coder for my workload, and I run Opus 4.6 for writing, planning and more interactive flows and also use GPT-5.2 xhigh for planning, review and deep work (leaving it alone for minutes/hours).

I have a custom [ccstatusline](https://github.com/sirmalloc/ccstatusline) and use [ccusage](https://www.npmjs.com/package/ccusage) and [@ccusage/codex](https://www.npmjs.com/package/ccusage) for some stats tracking as well, but besides that am pretty vanilla on my plugins/addons.

## Workflow

Historically I've leaned heavily into using Deep Research for research, but I've increasingly been migrating those ad-hoc queries into git repos/agentic coding tools for rapid iteration. Putting everything into agent-accessible MDs is a huge multiplier. 

As mentioned, I don't trick out my setup. There's a whole cottage industry of Claude Code plugins, custom skills, and meta-frameworks, and while I keep a repo/doc tracking and analyzing the major ones like [superpowers](https://github.com/obra/superpowers), [get-shit-done](https://github.com/glittercowboy/get-shit-done), etc., a well-written AGENTS.md seems to cover most of my needs. 

My **`AGENTS.md`** (and symlinked `CLAUDE.md`) is where the core of my current process lives. Each project has a custom AGENTS.md that I've been evolving. Versions are shared with the rest of my (human) team as well. Despite having boiled down my best practices, my AGENTS.md is not super long - currently about 250 lines.

The most important bits:
- points to `README.md` and `docs/` locations and dev environment
- Summarizes the project and project goals, design principles
- Has a structure/treemap of the key folders
- Lists the development philosophy and my preferred dev loop
- Outlines roles/lanes for different agents
- Specifies what documentation, tests, git commit practices, and other practical bits I want

Most of this is self-explanatory, but the most important part is probably my spec-driven development loop, especially the independent review loop. IMO, spec drift is where most people get in trouble with AI-assisted coding, and process is mostly about helping to keep you and your agents out of trouble on that front:

- RESEARCH and ANALYSIS are done before a PLAN is created
- Once the PLAN is created an IMPLEMENTATION (punchlist+worklog) is created - this is the core control point in my process and every major decision should be made here. I will usually work with at least 2 `planner` models to think through everything, and then work with the `coder` model to make sure that the IMPLEMENTATION is crystal clear for that model
- Once IMPLEMENTATION is locked down, the `coder` should be able to autonomously knock out all the milestones in a single pass:
  - Test-driven: test coverage is required before code is written
  - Coding: write a first pass, go through the entire punchlist, give a summary for reviewers
  - Review: I found using *independent* reviewers to be very important. All issues are gathered up and sent to the `coder` to fix 
  - Remediation: the `coder` goes through and fixes the reviews, and it's sent back from review (repeat this part until everything is green)
  - Analysis: I do a post/pre-analysis at each milestone to correct for any implementation drift, scoping, or decision-making 
- At the end of each sprint, I have started doing a STATUS review that's basically a post-mortem, implementation review, etc. that's useful for both me and for improving the process in the future 
- Ad-hoc development still largely adheres to this loop!

Despite basically not touching the code anymore, I feel like I still have a decent grip of what's being generated and I'm currently still very hands-on with managing my agents on coding sprints. The amount of engineering-effort from my side probably remains the same, but features (and new business lines) land much more quickly. While some people have adopted more chaotic flows, for now, I still try to keep the development as intentional as possible.

I also have an explicit "meta" rule at the end of my AGENTS.md:

```
## Meta: Evolving This File

This AGENTS.md is a living document. Update it when:
- You discover a workflow pattern that helps
- Something caused confusion
- A new tool or process gets introduced
- You learn something that would help the next person

Keep changes focused on process/behavior, not project-specific details (those go in docs/).
```

In practice though, my post-sprint analysis is where I'll review with my agents to see what actually needs to be changed or updated in the AGENTS.md.

## 30-Day Stats

Over the past 30 days, I've clocked in a pretty large amount of token usage, although 90-95% of those are cached tokens. I subscribe to ChatGPT Pro, and even at relatively high token usage, I have not been hitting any usage limits (the $200/mo is worth it). The Claude models I use via Bedrock and Vertex.

| Provider       | Tokens/mo | API Cost/mo |
|----------------|----------:|--------:|
| **Claude API** |      1.3B |  $1,211 |
| **OpenAI API** |      7.6B |  $2,153 |

What are these tokens used for? Over the past month, I've had multiple projects baking, including one optimizing GPU kernels, a new custom model training framework, multiple new evals, papers and blog posts and grant proposals, several training research plans, and also, most recently, two new 30K+ LOC greenfield projects.
