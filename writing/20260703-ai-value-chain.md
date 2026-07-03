# Frontier Labs, Enterprises, and the AI Value Chain

## Deployment programs, data flows, and value capture: analysis and evidence

July 3, 2026

---

## 1. Scope and claims

This document analyzes the claim that frontier AI labs use Forward Deployed Engineer (FDE) programs and enterprise deployments to absorb customer domain expertise, workflow knowledge, and data ("extraction," "sucking up alpha").

The narrow version of the claim — labs covertly training shared frontier weights on default enterprise content — is contractually barred by default across the four major providers, architecturally barred in some channels, and unsupported by public evidence. §9 covers it.

The supported version has three parts:

1. **Workflow intelligence is a priced asset class.** Expert-validated task distributions, grading rubrics, workflow environments, and tool-use trajectories are inputs to frontier post-training, with a third-party market (Surge, Mercor, Mechanize) that prices them. Deployments generate these artifacts as byproducts. §6 prices a representative engagement at low-to-mid seven figures.

2. **Lab business models force vertical conflict.** Inference pricing is falling under open-weight competition. Lab responses — first-party applications, FDE services, PE-backed deployment vehicles — put labs in direct competition with their enterprise customers, app-layer developers, and consulting partners. §4, §5, §7.

3. **The binding constraint on labs is customer exit, not regulation.** Enterprises can route commodity workloads to open-weight models at 3–10% of frontier cost, and can fine-tune open models on their own expert data to beat frontier models on their own tasks (Bridgewater/Thinking Machines, June 2026). §8.

Working conclusion: the market is stratifying. Frontier models retain the hardest task tier and services margin; enterprises retain their data, judgment, and (increasingly) inference; the enterprise LLM gateway is where the boundary gets enforced. §10 lists the three developments that would break this arrangement.

---

## 2. Three-layer model

The public debate conflates three claims with different evidence, legal posture, and remedies. Keep them separate.

| Layer | Claim | Evidence | Verdict |
|---|---|---|---|
| 1 — Weights | Labs train shared frontier weights on default enterprise content | OpenAI, Anthropic, Google, Azure enterprise terms: no training by default. Azure: customer data not available to OpenAI. Precedent: InstructGPT trained on API prompts pre-2023; OpenAI flipped API defaults March 2023. [1]–[4], [24] | Weak today. Forward risk from retention-policy changes and continual-learning research (§9). |
| 2 — Assets | Deployments produce evals, RL environments, trajectories, rubrics, and institutional know-how that improve lab capability and products | Described by the labs themselves (FDE flywheel, DeployCo case studies); priced by the RL-environment market; enterprise workflows named as the top procurement growth category. [5], [6], [16]–[20] | Strong. Legal and disclosed. Contract ownership of artifacts is the open variable. |
| 3 — Position | Demand visibility plus API control lets labs choose which application layers to enter and disadvantage downstream rivals | Windsurf access cutoff; Claude Code vs. Cursor; Thomson Reuters/RELX selloffs after Anthropic's Cowork vertical launches; VPA neutrality report with model legislation. [12]–[15], [29] | Strong as market-structure evidence. Requires no data misuse. |

Layer 1 is a privacy/contract question, Layer 2 a contract/IP question, Layer 3 a competition-policy question. Absence of Layer 1 evidence says nothing about Layers 2–3, and vice versa.

---

## 3. Moats by party

The extraction claim is a theory of moat transfer: deployments move defensible advantage from customers to labs. Auditing each party's actual moat shows which transfers occur, and that one transfer mechanism now runs in the opposite direction.

### 3.1 Frontier labs

| Moat | Status |
|---|---|
| Capability lead | 3–6 months over open-weight models at the mid-2026 frontier, per Coinbase's internal assessment [31], [32]; open weights within a few benchmark points except on long-horizon agentic tasks [33]. A product cycle, not a durable moat. |
| Compute/capital access | Durable. Protects the model layer, not inference pricing. |
| Data and eval assets | Post-training data now differentiates labs more than pretraining corpora did; procurement decisions reveal strategy [17]. This is the moat Layer 2 feeds, and why labs discuss $1B/yr-scale environment spend [16]. |
| Distribution | ChatGPT consumer position; Claude developer/enterprise position; first-party apps (Claude Code, Cowork) convert API access into workflow lock-in. Building this moat is the Layer 3 conflict. |
| Switching costs | Weak at the raw-API level. Agents, memory, and harnesses are attempts to manufacture them; enterprise gateways (§8.4) remove them again. |

### 3.2 Enterprises

| Moat | Status |
|---|---|
| Proprietary data and tacit judgment | Bridgewater result (§8.1): frontier models scored ~50% naive, <80% with expert-engineered prompts, on document-filtering tasks its investors consider trivial; the paper attributes this to judgment that experts cannot fully articulate in prompts. Fine-tuning a Qwen3-235B on expert labels reached 84.7%, above every frontier model tested, at 1/13.8 the inference cost [30]. The judgment is real, does not transfer through the context window, and is capturable in customer-owned weights. |
| Workflow context and integration | MIT NANDA reporting: ~95% of enterprise genAI pilots show no P&L impact, attributed to integration and organizational failure rather than model capability [28]. A Stanford figure (models interchangeable in 42% of successful deployments) points the same direction but remains untraced to a primary source. This moat does not leave with an FDE. |
| Regulation and compliance | Coinbase's stated defense: 13 years of licensing, audits, and compliance infrastructure that labs do not replicate, which is why labs "leave whole industries open" [32]. Bargaining power is highest in regulated verticals; those are also where sovereign/self-hosted offers land. |
| Customer distribution and telemetry | Systems-of-record (Thomson Reuters, RELX class) hold customer relationships and usage telemetry labs cannot reach. The Cowork selloffs repriced how contestable this is; Brookings' counter-case is that regulated buyers will still demand external vendors to validate mission-critical software [12]. |

### 3.3 Application-layer companies

The most exposed party. The determining variable is weight ownership.

**Without own models** (Windsurf class; most of the 2025 YC AI-native cohort): assets are harness/UX design, vertical evals, and speed. All are replicable by a lab; all depend on API access the lab controls. Anthropic terminated Windsurf's Claude access during OpenAI acquisition talks while ramping Claude Code against the same customers [13], [29]. Mitigations: multi-model abstraction from day one, gateway-level portability, contractual nondiscrimination.

**With own or tuned models** (Cursor building training tasks from its own user telemetry [16]; Harvey-class verticals; any Tinker customer): deployment-surface telemetry becomes training data the company owns, converting distribution into a weights-level moat. The mechanism is identical to lab-side Layer 2 collection, pointed the other way. Whoever owns the deployment surface owns the data flywheel.

### 3.4 Hyperscalers, data vendors, consultancies

Hyperscalers hold compute, enterprise trust, and architectural neutrality sold as a product: Azure documents that OpenAI cannot access Azure OpenAI customer data [3]; Microsoft Frontier Company markets "customers keep the results of the work," framed by Reuters against enterprise fear that labs learn enough to compete in coding and law [11]. Data vendors (Surge: >$1B revenue; Mercor: $10B valuation; Mechanize: $500K engineer salaries, works with Anthropic) hold expert networks and QA infrastructure; their prices define Layer 2's market value [16]–[20]. Consultancies hold client relationships and change-management capacity, and are both DeployCo investors (Bain, McKinsey, Capgemini) and its competitive targets [8].

---

## 4. Lab business models

Lab behavior follows from the revenue picture.

**Inference pricing under open-weight pressure.** GLM 5.2: $1.40/M input tokens vs. Opus 4.8 at $5, with a higher SWE-bench Pro score [36]. Lindy migrated from Claude to DeepSeek V4, reporting AI costs had exceeded payroll before the switch; Microsoft is evaluating a fine-tuned DeepSeek V4 for Copilot Cowork [33]. Coinbase projects 80% of its workloads on models 99% cheaper than frontier within 12–18 months [31], [35]. Box's Levie calls that split "a bit extreme" but agrees usage stratifies into high-end and high-volume tiers [37]. Direction is uncontested; the migration is a named risk to lab IPO narratives [33].

**Subscriptions as usage-data acquisition.** SemiAnalysis estimated a $200/month plan delivers ~$8–14K of tokens at list price. The subsidy buys usage signal, feedback data, and habit formation.

**Services.** OpenAI Deployment Company: $4B initial investment, $10B pre-money, 17.5% guaranteed minimum investor return, capped profits, majority OpenAI control, ~150 engineers via the Tomoro acquisition, 19 PE/consulting backers whose portfolios span 2,000+ companies [5], [7], [8]. Anthropic: reported $1.5B JV with Blackstone, Goldman Sachs, and Hellman & Friedman to deploy into PE portfolios (WSJ via Reuters; unverified by Reuters) [9]. Two readings, both consistent with the facts: (a) an institutionalized Layer 2/3 collection vehicle with cross-portfolio visibility; (b) lower-margin consulting revenue entered because model-layer pricing power is eroding. Reading (b) does not reassure customers — a lab that needs services margin needs the engagement flywheel to produce reusable assets.

**First-party applications.** Claude Code against Cursor/Copilot, then Cowork legal/financial plugins against Thomson Reuters/RELX [12]. Pattern: observe aggregate demand through the API, build the winning application internally, capture application margin. Uses no individual customer's data; this is Layer 3 in its complete form.

**The inverted model.** Thinking Machines' Tinker sells the training loop and returns the weights: customer brings data, rents RL/fine-tuning infrastructure, owns the resulting model; nothing aggregates into a shared system [30]. Combined with open-weight bases (Qwen, GLM, Kimi, DeepSeek), this completes a stack containing no frontier lab: open base + rented training infra + customer expert data + self-hosted inference. Bridgewater published the proof of concept and named the strategy "differentiated intelligence."

---

## 5. Relationship map

Seven bilateral relationships, each simultaneously cooperative and adversarial, all renegotiated in 2025–26.

| Relationship | Cooperative face | Adversarial face | 2025–26 flashpoints |
|---|---|---|---|
| Lab ↔ Enterprise | Vendor/customer; FDE co-development | Customer is a data source; lab is a prospective vertical competitor | Karp's buyer checklist: "are you keeping the data, are you going to enter our business" [26], [27]; Fable 30-day retention → Microsoft limits employee use [21], [22] |
| Lab ↔ App layer | API supplier; platform partner | Supplier is competitor and gatekeeper; access is revocable | Windsurf cutoff; Claude Code vs. Cursor; SpaceX/xAI signaling Cursor acquisition [13]–[15] |
| Lab ↔ Hyperscaler | Compute supplier, investor, sales channel | Channel architecture blocks the lab's data access; hyperscaler builds rival deployment arms | Azure data firewall [3]; Microsoft Frontier Company positioning [11]; Microsoft evaluating DeepSeek for Copilot [33] |
| Lab ↔ Data vendor | Environment/rubric procurement | Labs in-house to keep training priorities confidential; vendors move up-stack | Anthropic's ~$1B environment discussions; OpenAI building an in-house human-data team [16], [17] |
| Lab ↔ Consultancy | Delivery partnerships (Accenture, Deloitte, PwC; Bain/McKinsey as DeployCo investors) | DeployCo targets the consulting TAM | DeployCo launch; investor-as-competitor structure [5]–[8] |
| Lab ↔ PE | Capital plus captive distribution into portfolios | Portfolio companies are simultaneously investors, customers, and data sources | Anthropic/Blackstone–H&F–Goldman JV [9]; DeployCo's 19 backers [8] |
| Enterprise ↔ Open-model ecosystem | Exit option; cost discipline; data sovereignty | Legal/geopolitical exposure: GLM and Kimi named in a congressional security probe weeks before Coinbase's adoption announcement [33], [36] | Coinbase defaulting to GLM/Kimi; Bridgewater tuning Qwen3-235B [30], [31] |

Two structural facts. Each row contains the same entity in conflicting roles, which is what makes the VPA nondiscrimination proposal legible as ordinary infrastructure regulation. And the last row prices all the others: lab leverage in every relationship is capped by the enterprise's cost of exit to the open stack, which fell through H1 2026.

---

## 6. Market pricing of workflow intelligence (Layer 2)

Epoch AI's January 2026 FAQ (18 interviews across environment startups, neolabs, and frontier labs) supplies the price sheet [16]:

| Item | Price |
|---|---|
| Vendor contracts | Six to seven figures per quarter; one observed range $300–500K |
| Website replica ("UI gym") | ~$20K |
| High-fidelity clone of a complex product (Slack-class) | ~$300K |
| Tasks | $200–$2,000 typical; $20K rare, for complex SWE tasks |
| Exclusivity premium | 4–5× over non-exclusive |
| RL compute consumed per task (Mechanize estimate) | ~$2,400 — low-quality tasks waste it [18] |
| Anthropic environment spend under discussion | >$1B/yr (The Information, Sep 2025) |
| OpenAI projected 2026 R&D compute, for scale | ~$19B |

Enterprise workflows (Salesforce navigation, expense reports, spreadsheets, CRM/ERP operations) are the named next procurement growth category [16]. SemiAnalysis documents the pipeline: trajectories, telemetry, and expert rubrics feed mid-training and RL; unlike pretraining, where every lab had the same internet corpus, procurement now constitutes strategy [17].

**Engagement valuation.** A deep FDE engagement of the type OpenAI documents (John Deere: "hundreds of real-world examples reviewed with domain experts," custom evaluation systems [6]) yields:

| Byproduct | Market proxy | Implied value |
|---|---|---|
| ~300 expert-validated tasks with graders | $200–$2,000/task | $60K–$600K non-exclusive |
| De facto exclusivity of the task distribution | 4–5× premium | $240K–$3M |
| Access to a real production environment | $20K–$300K for synthetic replicas; real access exceeds replica value | ≥$300K equivalent |
| Difficulty calibration from real failure distributions | No market quote. Epoch: tasks need ~2–3% minimum pass rates; ~70% of vendor-produced tasks get discarded in QA | Unpriced but material |
| Field knowledge and roadmap signal | No market | Unpriced; strategic rather than liquid |

Total: low-to-mid seven figures per serious engagement at market proxies — the same order as engagement fees. The customer co-funds an asset the lab otherwise buys from Mercor. The Bridgewater result removes the remaining doubt about whether such data converts to capability: +6.5 accuracy points over the best frontier model on the target tasks [30]. The open variable per engagement is contract terms: who owns the tasks, graders, and trajectories, and whether the provider may generalize them.

Bounds: environment spend runs one to two orders of magnitude below compute spend [16]; non-exclusive market prices cap single-customer workflow value at hundreds of thousands to low millions; and vendors' reported bottleneck is expert QA at scale — which an FDE engagement obtains free from the customer's own staff.

---

## 7. Vertical foreclosure and policy response (Layer 3)

Market structure: Google, OpenAI, and Anthropic held ~90% of the $37B enterprise LLM API market at end-2025 (Menlo Ventures via Brookings); Anthropic 40%, OpenAI 27%, Google 21% [12].

Case record: Anthropic cut Windsurf's Claude access during OpenAI acquisition talks — its chief science officer: "I think it would be odd for us to be selling Claude to OpenAI" — while ramping Claude Code at the same customer base. Anthropic cut OpenAI's access in August 2025 over GPT-5 pre-launch testing. Anthropic's February 2026 Cowork legal/financial plugins triggered selloffs in RELX and Thomson Reuters [12], [29].

Policy response: VPA's "AI Neutrality" (Ramzanali & Rajan, Jan 2026) proposes that FM providers offering external APIs may not unreasonably discriminate among similarly situated customers in access, latency, cost, or quality of service, with security and unlawful-use exceptions; includes model legislation [13], [14]. Follow-ups: a Ramzanali/Wheeler Brookings op-ed adding the SpaceX/xAI/Cursor integration risk, and VPA's "After the AI Crash" (Mar 2026) proposing structural separation of models from data centers, utility-style regulation, and a ban on extractive business models [15].

Layer 3 is the best-evidenced form of the extraction claim because it needs no data misuse: aggregate demand shape visible through the API is sufficient targeting information for first-party product decisions.

---

## 8. Enterprise countermeasures

### 8.1 Custom training on expert data (Bridgewater × Thinking Machines, June 30, 2026)

The paper ("Learning to Replicate Expert Judgment in Financial Tasks," Bridgewater AIA Labs on Tinker [30]) reports, across six investor document-filtering tasks:

| Result | Number |
|---|---|
| Frontier models, naive prompting (Opus 4.6/4.8, Gemini 3.1 Pro, GPT-5.4/5.5) | ~47–50% avg accuracy |
| Frontier models, expert-engineered prompts | <80% |
| Fine-tuned Qwen3-235B on expert labels | 84.7% avg; 29.8% fewer errors than best frontier model |
| Inference cost vs. frontier | 13.8× lower |
| Marginal frontier upgrade economics | GPT-5.4 costs 43% more than 5.2 for small accuracy gain |

Method: expert labels with a verification scheme routing disagreements back to experts; training recipe of interleaved batching, CISPO with asymmetric clipping, and on-policy distillation with promoted teachers — reproducible by a competent ML team on rented infrastructure. The paper attributes the frontier-model ceiling to judgment experts cannot fully articulate in prompts, and names the strategy "differentiated intelligence."

Four consequences for this analysis. (1) It contradicts the position that general capability dominates domain data for tacit-judgment tasks: the judgment does not transfer through the context window. (2) It demonstrates capture-by-the-owner: the same expert-label mechanics a lab would use work in customer-owned weights. (3) The author matters: Bridgewater's business is proprietary investment judgment, and it chose to compile that judgment into its own weights rather than expose it to a frontier vendor. (4) It cuts both ways: it confirms that expert-labeled enterprise data converts to capability, i.e., the asset the extraction claim is about exists. Each FDE engagement producing such labels improves someone's model; the contract decides whose.

### 8.2 Routing and open-weight defaults (Coinbase, June 2026)

Armstrong's published playbook [31], [34]–[36]: open-weight defaults (GLM 5.2, Kimi 2.7) through an internal LLM gateway (LightLLM-derived middleware); difficulty-based routing with frontier escalation preserved (91% of engineers never hit prior usage caps); cache hit rate raised 5%→60%; per-team spend visibility. Outcome: AI spend cut ~50% while token usage grows. Projection: 80% of workloads on 99%-cheaper models within 12–18 months. Plus the moat half: Coinbase trains on its own Advisor human-approval signal to beat general models on its core task, protected by compliance infrastructure labs do not replicate [32].

Reaction from operators marks this as forming consensus: Levie (usage stratifies high-end/high-volume), Harvey's Weinberg ("intelligence allocation is going to be extremely important"), Glean's Gentilcore ("everyone technical already knows this"; only financial markets still extrapolate frontier prices to infinite scale) [37].

Caveats: GLM and Kimi were named in a congressional security probe before Coinbase's announcement; self-hosting resolves data routing to Chinese APIs but not model provenance [33], [36]. These argue about which open models, not whether.

### 8.3 Sovereign deployment (Palantir/NVIDIA)

Open Nemotron models deployed in customer-controlled environments, sold with Karp's buyer checklist: is the vendor keeping the data, and will it enter your business [26], [27]. Self-interested, and commercially significant: enterprises now hold three exits (hyperscaler-isolated closed models, open-stack self-hosting, sovereign vendor deployments), each marketed against lab data exposure.

### 8.4 The gateway as enforcement point

All three countermeasures run through an enterprise-owned LLM gateway that: routes by task difficulty × data sensitivity; enforces per-provider data posture in code (which channels — training, feedback, retention, telemetry — each route may expose, per the §9 channel taxonomy); maintains multi-model portability, which removes lab-manufactured switching costs; and hosts the escalation policy deciding which fraction of work merits frontier pricing. Coinbase's LightLLM middleware is the public reference implementation; routing/orchestration is emerging as its own product category [37]. The gateway converts Layer 1/2 posture from contract clause to enforced infrastructure, and its operator holds the demand-shaping visibility that labs otherwise get through their APIs.

### 8.5 Effect on the extraction claim

Exit caps extraction twice. Price: labs cannot charge above the open-stack alternative for commoditized workloads, compressing the margin that funds everything else. Behavior: retention-policy changes now carry an observable cost — Anthropic's Fable 30-day retention requirement (two years if classifier-flagged) was followed within weeks by Microsoft limiting employee use [21], [22]. This is the first clean natural experiment on whether market discipline constrains data-policy drift; it constrained.

The protection is asymmetric. It covers enterprises with ML capacity (Bridgewater, Coinbase) and regulated-vertical moats. It covers thin app-layer companies without weights poorly; their remedies remain contractual nondiscrimination, multi-model architecture, and acquiring fine-tuning capability — which Tinker-class infrastructure repriced downward.

---

## 9. Layer 1: enterprise data and model training

Current state. Enterprise no-default-training commitments are consistent across OpenAI, Anthropic, Google Cloud, and Azure; Azure adds architectural separation (customer prompts, completions, embeddings, and training data not available to OpenAI) [1]–[4]. Disclosed side channels remain, none covert:

| Channel | Training-relevant? | Notes |
|---|---|---|
| Default inference I/O | No, under business terms | Core commitment [1]–[4] |
| Abuse/safety logs | No | 30-day default retention; Fable: 2 years if flagged [21], [22] |
| Stateful features, files, vector stores | No by default | Persist production examples; deletion and tenancy terms apply [1], [3] |
| Customer fine-tuning data | Customer-scoped | Not shared foundation training by default [1], [3] |
| Opt-in feedback / data sharing | Yes | Anthropic feedback usable for training with full-conversation retention; OpenAI offers complimentary tokens for opt-in traffic sharing [1], [2] |
| Evals, rubrics, environments, trajectories | Often yes | The Layer 2 asset class; ownership set by contract [16]–[20] |
| FDE field knowledge, roadmap signal | Not as data | Shapes products and competitive strategy [5], [6] |

Legal layer. *United States v. Heppner* (SDNY, Rakoff, Feb 2026): 31 defense-strategy documents a securities-fraud defendant generated in consumer-tier Claude held neither privileged nor work product; the consumer privacy policy (training use, disclosure to authorities) defeated any reasonable expectation of confidentiality, with the court noting possible waiver over the underlying attorney communications [25]. Consequence for trade-secret posture: product-tier misuse can destroy "reasonable secrecy measures" before any training question arises.

Forward risks. Retention terms are product- and risk-tier-dependent and revisable (Fable), though §8.5 shows revision now carries a market price. Continual learning — models that learn on the job, with deployment experience written back to weights — is a stated research goal (Dwarkesh Patel's framing: models "privy to so much tacit organization- and domain-specific knowledge" that not training on it is wasteful); a lab that solves it makes deployment logs maximally valuable and its weights the repository of customers' tacit knowledge, shared across every copy. Differentiated intelligence (§8.1) is the same technical goal with customer-owned weights. Which architecture wins is the highest-stakes open question in this document.

---

## 10. Equilibrium and instabilities

The settlement visible as of July 2026:

**Inference stratifies.** Frontier models hold the hardest tier (long-horizon agents, novel reasoning, Fable-class enterprise-workflow specialization); open and custom models take the high-volume remainder at 1–10% of cost [31]–[37].

**Learning stratifies.** Generic capability accrues to labs via purchased environments, disclosed product partnerships (Benchling×Anthropic, OpenAI×Shopify/Stripe), first-party app telemetry, and consumer data. Organization-specific judgment accrues to whoever owns the deployment surface and the labels — after Bridgewater, achievably the enterprise. FDE engagements sit on this boundary; artifact-ownership terms decide each case.

**Services are the contested middle.** DeployCo, the Anthropic/PE JV, Microsoft Frontier Company, AWS's $1B embedded-engineer unit, and incumbent consultancies compete to perform integration — the position that sees workflows, produces artifacts, and shapes roadmaps. Hyperscalers differentiate on not learning from the customer [11]; labs differentiate on frontier proximity. Enterprises price the trade.

Three developments would break this:

1. **A closed lab solves continual learning.** The learning-stratification boundary collapses in the labs' favor; deployment access becomes the decisive asset.
2. **Chinese open weights become unusable for regulated Western enterprises** (the congressional-probe thread [33]). The cheap exit narrows; lab pricing power returns. Western open-weight releases and sovereign stacks become the remaining counterweight.
3. **An AI-market financial correction** (the VPA "After the AI Crash" scenario [15]) forces labs to monetize retained data and vertical positions. Revocable guarantees get tested under distress rather than growth.

---

## 11. Enterprise playbook

Contractual controls (unchanged from prior draft): derivative-use restrictions beyond no-training (task descriptions, evals, graders, rubrics, field notes, telemetry, process maps, synthetic data); artifact ownership with deletion/export rights; research/product-team firewalls; reciprocal competitive-use covenants; feedback channels disabled by default; per-endpoint retention audit; API nondiscrimination clauses; PE/consultancy conflict disclosures; canary testing for leakage.

Architectural controls:

1. **Own the gateway.** Route by sensitivity × difficulty; enforce per-provider data posture in code; keep multi-model portability warm. The gateway is both the enforcement point and the negotiating leverage.
2. **Classify workflows into three regimes.** Commodity → open weights, self-hosted or cheap API. Frontier-worthy → closed models under negotiated enterprise terms with the contract stack above. Proprietary-judgment → customer-owned fine-tunes on expert labels (the Bridgewater pattern).
3. **Treat expert labels and human approvals as owned assets.** Log them; decide deliberately whether each flows to a vendor eval set or the internal training set. Armstrong: "the decision you make today is the dataset you own tomorrow" [32].
4. **App-layer companies:** assume API access is revocable (Windsurf); abstract providers early; treat fine-tuning capability as insurance.
5. **Sequence FDE engagements** onto workflows classified commodity or shareable. Engagement byproducts should be low-value to a competitor by construction, with contract terms as the second line rather than the only line.

---

## 12. Evidence grading and open questions

| Claim | Grade | Basis |
|---|---|---|
| Enterprise no-default-training commitments are real | Strong | Official OpenAI/Anthropic/Azure/Google docs [1]–[4] |
| FDE deployments produce reusable workflow/eval/roadmap signal | Strong | OpenAI's own materials; John Deere case [5], [6] |
| RL environments and expert rubrics are a scarce, priced input | Strong | Epoch, SemiAnalysis, Mechanize, vendor reporting [16]–[20] |
| Labs, hyperscalers institutionalizing FDE-style deployment | Strong | Announcements plus Reuters/Axios reporting [5]–[11] |
| Platform control used against app-layer rivals | Strong | Windsurf, OpenAI cutoff, Cowork selloffs; VPA/Brookings [12]–[15], [29] |
| Enterprise tacit judgment resists prompting, yields to fine-tuning | Strong | Bridgewater/TML results [30] |
| Open-weight exit operational at enterprise scale | Strong | Coinbase in production; operator consensus [31]–[37] |
| A deep FDE engagement yields low-to-mid seven figures of training-asset value | Moderate | Back-of-envelope on Epoch prices; depends on task count, rights, fidelity [6], [16] |
| Market discipline constrains retention drift | Moderate | One natural experiment: Fable → Microsoft limits [21], [22] |
| Enterprise content flows into shared frontier weights today | Weak | No public proof; contradicted by default terms [1]–[4] |
| Continual learning makes deployment logs decisively more valuable | Unresolved | Research direction; feasibility and timeline open |

Open questions, ranked:

1. Who wins continual learning — centralized (lab weights) or differentiated (customer weights)? Everything downstream depends on it.
2. Contract forensics: actual FDE/DeployCo engagement terms — derivative-use, artifact ownership, research-team firewalls, post-engagement deletion.
3. Replication cost of the Bridgewater result for a mid-size enterprise on Tinker-class infrastructure. Bridgewater's all-in cost is unstated; this number sets the effective extraction ceiling.
4. Trace the Stanford 42% interchangeability claim to its primary source.
5. Track first-party lab app launches against enterprise-customer density by vertical — the cleanest Layer 3 signal.
6. Outcome of the Chinese open-weights policy fight; determines whether the §8 counterforce survives for regulated US enterprises.

---

## 13. References

[1] OpenAI, Enterprise privacy. https://openai.com/enterprise-privacy/ — Business no-default-training; post-March-2023 API defaults; opt-in sharing.
[2] Anthropic, Commercial Terms of Service. https://www.anthropic.com/legal/commercial-terms — Customer Content no-training clause; separate feedback clause; customer restrictions on building competing models.
[3] Microsoft Learn, Data privacy for Azure/Foundry-hosted models. https://learn.microsoft.com/en-us/azure/foundry/responsible-ai/openai/data-privacy — Customer data not available to OpenAI; no training without permission.
[4] Google Cloud, Gemini Enterprise ZDR. https://docs.cloud.google.com/gemini-enterprise-agent-platform/resources/zero-data-retention — No training without permission; retention exceptions enumerated.
[5] OpenAI, Deployment Company announcement. https://openai.com/index/openai-launches-the-deployment-company/ — $4B+, Tomoro, 19 partners, majority OpenAI control.
[6] Deploy.co, Forward deployed engineering. https://deploy.co/ — FDE flywheel; BBVA and John Deere case studies.
[7] Reuters, OpenAI $4B unit, May 11, 2026. https://www.reuters.com/business/openai-creates-new-unit-with-4-billion-investment-aid-corporate-ai-push-2026-05-11/
[8] Axios, DeployCo valuation and terms, May 11, 2026. https://www.axios.com/2026/05/11/openai-deployco-private-equity — $10B pre-money; 17.5% guaranteed return; capped profits.
[9] Reuters, Anthropic $1.5B JV report, May 4, 2026. https://www.reuters.com/legal/transactional/anthropic-nears-15-billion-ai-joint-venture-with-wall-street-firms-wsj-reports-2026-05-04/ — Via WSJ; not independently verified.
[10] Reuters, AWS $1B embedded-engineer unit, Jun 30, 2026. https://www.reuters.com/business/retail-consumer/amazons-aws-commits-1-billion-toward-new-unit-embedded-ai-engineers-2026-06-30/
[11] Reuters, Microsoft Frontier Company, Jul 2, 2026. https://www.reuters.com/business/retail-consumer/microsoft-launches-firm-help-companies-adopt-ai-with-25-billion-2026-07-02/ — $2.5B; customers keep results; framed against lab-expertise fears.
[12] MacCarthy, Brookings, "What happens when AI companies compete with their customers?", Mar 12, 2026. https://www.brookings.edu/articles/what-happens-when-ai-companies-compete-with-their-customers/
[13] Ramzanali & Rajan, VPA, "AI Neutrality" (report PDF). https://cdn.vanderbilt.edu/vu-URL/wp-content/uploads/sites/412/2026/01/28222934/AI-Neutrality-.pdf
[14] VPA Substack, "Net Neutrality for AI", Jan 29, 2026. https://vanderbiltpolicyaccelerator.substack.com/p/net-neutrality-for-ai
[15] VPA, Governing AI papers page ("After the AI Crash", Mar 26, 2026). https://www.vanderbilt.edu/vanderbilt-policy-accelerator/governing-artificial-intelligence/
[16] Denain & Barber, Epoch AI, "An FAQ on Reinforcement Learning Environments", Jan 12, 2026. https://epoch.ai/gradient-updates/state-of-rl-envs
[17] Kourabi & Patel, SemiAnalysis, "RL Environments and RL for Science", Jan 12, 2026. https://newsletter.semianalysis.com/p/rl-environments-and-rl-for-science
[18] Mechanize, "Cheap RL tasks will waste compute". https://www.mechanize.work/blog/cheap-rl-tasks-will-waste-compute/
[19] Reuters, Surge AI raise, Jul 1, 2025. https://www.reuters.com/business/scale-ais-bigger-rival-surge-ai-seeks-up-1-billion-capital-raise-sources-say-2025-07-01/
[20] Business Insider, Mercor contractor spend, Oct 2025. https://www.businessinsider.com/mercor-pays-million-per-day-human-contractors-training-ai-ceo-2025-10
[21] Anthropic, Claude Fable product page. https://www.anthropic.com/claude/fable — 30-day retention requirement.
[22] Reuters, Microsoft limits Fable use, Jun 10, 2026. https://www.reuters.com/technology/microsoft-limits-employee-use-anthropics-claude-fable-5-over-data-retention-2026-06-10/ — 30 days; 2 years if flagged.
[23] The Verge, Anthropic consumer training policy. https://www.theverge.com/anthropic/767507/anthropic-user-data-consumers-ai-models-training-privacy
[24] Ouyang et al., InstructGPT, arXiv:2203.02155. https://arxiv.org/abs/2203.02155 — API-submitted prompts in the training pipeline.
[25] Reuters Legal on *US v. Heppner*, Mar 24, 2026. https://www.reuters.com/legal/transactional/artificial-intelligence-tools-third-party-by-any-other-name--pracin-2026-03-24/
[26] Axios, "The revolt against U.S. AI labs", Jul 2, 2026. https://www.axios.com/2026/07/02/karp-palintir-openai-anthropic-amodei
[27] Business Insider, Karp critique, Jul 2026. https://www.businessinsider.com/alexander-karp-criticizes-ai-companies-token-costs-2026-7
[28] Tom's Hardware on MIT NANDA GenAI Divide. https://www.tomshardware.com/tech-industry/artificial-intelligence/95-percent-of-generative-ai-implementations-in-enterprise-have-no-measurable-impact-on-p-and-l-says-mit-flawed-integration-key-reason-why-ai-projects-underperform — Primary MIT report not yet sourced.
[29] Wired, "Anthropic revokes OpenAI's access to Claude". https://www.wired.com/story/anthropic-revokes-openais-access-to-claude
[30] Su, Zhu, Xiao, Alur, Kang (Bridgewater AIA Labs) with Thinking Machines Lab, "Learning to Replicate Expert Judgment in Financial Tasks", Jun 30, 2026. https://thinkingmachines.ai/news/learning-to-replicate-expert-judgment-in-financial-tasks/ — Results in §8.1; coins "differentiated intelligence."
[31] Yahoo Finance/Business Insider, Coinbase AI cost strategies, Jun 2026. https://finance.yahoo.com/technology/ai/articles/coinbases-ceo-outlined-5-strategies-053434539.html
[32] The AI Corner, Armstrong interview summary, Jul 2026. https://www.the-ai-corner.com/p/brian-armstrong-coinbase-1200-ai-agents-operating-model-2026 — Secondary summary; verify against the primary interview before quoting.
[33] TechTimes, Coinbase/Chinese-model legal risk, Jun 28, 2026. https://www.techtimes.com/articles/319248/20260628/coinbase-cuts-ai-spend-50-chinese-models-legal-risk-its-ceo-didnt-lead.htm — Congressional probe; Lindy migration; Microsoft/DeepSeek evaluation.
[34] PANews, Coinbase gateway/caching detail, Jun 27, 2026. https://panewslab.com/en/articles/019f08e4-fef0-70ca-9cdc-572a6426e81b
[35] BigGo Finance, Armstrong interview coverage, Jun 2026. https://finance.biggo.com/news/77dd3c6888face61 — LightLLM-derived middleware; 80%/99% projection.
[36] MLQ News, Coinbase GLM/Kimi switch, Jun 2026. https://mlq.ai/news/coinbase-switches-to-chinese-ai-models-glm-and-kimi-cuts-ai-spending-by-50/ — $1.40 vs. $5 per M input tokens; SWE-bench Pro comparison.
[37] Tekedia, ecosystem reactions to Armstrong, Jun 2026. https://www.tekedia.com/coinbase-ceo-brian-armstrong-urges-shift-to-cheaper-ai-models-signaling-end-of-the-tokenmaxxing-era/ — Levie, Weinberg, Gentilcore, Andreessen, Chaumond quotes.

Adjacent sources from the research thread, not directly cited above: Wing VC on RL-environment market consolidation (3–5 predicted winners); Stratechery on subscription subsidies, Fable retention, and the commoditization case (paywalled; cited from memory); Dwarkesh Patel, "The next paradigm" (continual learning).

**Source-quality notes:** Stanford 42% claim untraced to primary. [32] is a secondary interview summary. Stratechery arguments unverifiable against paywalled text. Bridgewater's all-in training cost unstated in [30]. Post-January-2026 claims verified against sources retrieved July 3, 2026.
