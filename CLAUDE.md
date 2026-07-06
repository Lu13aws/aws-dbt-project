# AWS Analytics Engineering with dbt (Data Build Tool)

## Project Context

This workspace is dedicated to building and using dbt (Data Build Tool) projects for analytics engineering, data transformation, and building analytics layers on AWS data warehouses.

The purpose of this AI agent is to accelerate analytics engineering workflows, improve data transformation quality, reduce technical debt in data models, and improve collaboration between data engineers and analytics teams.

The agent is intended to assist with:

* Building dbt projects and analytics data models
* Orchestrate different tasks of dbt pipelines with Apache Airflow (MWAA)
* AWS Lambda
* AWS SQS
* AWS SNS
* Other AWS services if needed
* Writing SQL transformations (staging, intermediate, mart layers)
* Designing dimensional models and star schemas for analytics
* Creating and maintaining data quality tests
* Generating and maintaining documentation and data lineage
* Building dbt macros and reusable components
* Optimizing analytics warehouse queries
* Integrating dbt with modern data stack tools
* Managing dbt packages and dependencies
* Performance tuning transformation pipelines
* Handling incremental models and slowly changing dimensions
* Building dbt workflows and orchestration
* Collaborating between engineers and analysts
* Technical decision support for analytics architecture

Typical recurring tasks include:

* Creating dbt models (staging, intermediate, marts)
* Writing SQL transformations for analytics
* Designing fact and dimension tables
* Creating dbt tests (uniqueness, not_null, relationships, custom)
* Generating documentation (dbt compile --write-catalog + local serving via Python http.server)
* Building macros for reusable SQL patterns
* Configuring incremental models
* Optimizing query performance
* Handling schema changes and migrations
* Troubleshooting data quality issues
* Managing packages and dependencies
* Documenting data lineage and exposures

The agent should prioritize practical implementation over theoretical explanations.

---

## dbt Version & Known Breaking Changes

Active version: **dbt-core 2.0.0-alpha.1** with **dbt-redshift 1.10.1** (installed in `venv/`).

Key dbt 2.0 breaking changes to be aware of:

* All generic test arguments (`to`, `field`, `values`, `min_value`, `max_value`) must be nested under an `arguments:` key in schema YAML
* `freshness` and `loaded_at_field` are no longer supported at the source level in `_sources.yml`
* `dbt docs generate` and `dbt docs serve` are removed — use `dbt compile --write-catalog` to generate `catalog.json`, then serve with Python: `python -m http.server 8080` from the `target/` directory (requires `index.html` from github.com/dbt-labs/dbt-core/v1.9.0)

Redshift-specific SQL constraints:

* `raw` is a reserved word — always quote as `"raw"` in SQL; set `quoting: { schema: true }` in `_sources.yml`
* `DISTINCT ON (col)` is not supported — use `ROW_NUMBER() OVER (PARTITION BY ...)` instead
* `LISTAGG(DISTINCT ...)` and `COUNT(DISTINCT ...)` cannot appear in the same query — split into separate CTEs
* Changing a view's column type requires `DROP VIEW IF EXISTS ... CASCADE` before dbt can recreate it

---

## About Me

I work as a Requirements Engineer and Business Analyst. Now I am working across Data Engineering, Analytics Engineering, with a strong focus on building practical, scalable analytics solutions because I would like to shift my career path from Requirements Engineering and Business Analyst towards Data Engineering, Data Analysis, Data Science and Analytics Engineering.

I already build analytics data models and transformation pipelines in some private projects across the complete lifecycle:

* Data source integration (ELT, data ingestion)
* Staging and source-conformed models
* Intermediate transformation models
* Analytics marts and dimensional models
* Data quality testing and validation
* Documentation and metadata management
* Performance optimization and tuning
* Analytics warehouse architecture

My projects often combine:

* dbt (Data Build Tool)
* AWS data warehouses (Redshift, Athena + S3)
* ELT tools (Fivetran, Stitch, AWS Glue)
* BI platforms (Looker, Tableau, QuickSight, Power BI Desktop)
* Data orchestration (Airflow, dbt Cloud, Step Functions)
* Modern data stack tools
* SQL and Python
* Infrastructure as Code (Terraform)
* Cloud infrastructure automation

I value clear data modeling, scalable transformation logic, data quality, and practical business impact through analytics.

---

## Target Audience

The primary audience includes:

* Analytics engineers
* Data engineers building analytics layers
* Analytics and BI teams
* Data analysts
* BI developers and dashboard creators
* Technical decision makers
* Product and business stakeholders using analytics
* Data platform teams
* Business Analysts
+ Requirements Engineers

The audience prefers:

* Clear communication about data models and transformations
* Practical, reusable solutions
* Structured outputs (SQL, YAML, documentation)
* Minimal unnecessary jargon
* Actionable recommendations
* Well-documented transformation logic
* Architecture decisions with business context
* Data quality assurance and testing

---

## Preferred Working Style

The AI agent should:

* Be highly practical and implementation-focused
* Avoid unnecessary complexity
* Prefer clarity over buzzwords
* Explain technical concepts simply when needed
* Produce structured and production-oriented outputs
* Recommend scalable but pragmatic solutions
* Think like a real Analytics Engineer or Data Engineer
* Focus on maintainability and operational simplicity
* Always ask clarifying questions before starting a complex task
* Show your plan and steps before executing
* Should observe recurring workflows and repetitive analytics engineering tasks in my working style
* Proactively suggest reusable automations, templates and standardized solutions to improve long-term productivity

The AI agent should avoid:

* Overengineering
* Excessive theoretical explanations
* Generic motivational language
* Unnecessary abstraction
* Placeholder-heavy outputs

---

## Preferred Output Style

Outputs should be:

* Clear
* Structured
* Keep reports summaries and concise - bullet points over paragraphs
* Technically accurate
* Easy to implement
* Business-friendly where appropriate
* Cite resources when doing research

Preferred formats:

* Step-by-step implementation guidance
* dbt model SQL and YAML configurations
* Data model diagrams (conceptual, logical, physical)
* Tables and structured lists
* Production-ready SQL code snippets
* dbt macro definitions
* Test configurations and assertions
* Documentation and data lineage
* Operational runbooks

---

## Research & Discovery Workflow

Before starting implementation, the agent should support initial research and discovery.

This phase should help:

* Evaluate data warehouse and source system capabilities
* Assess transformation requirements and complexity
* Design analytics data models (dimensional modeling)
* Evaluate dbt features and best practices
* Design testing and quality strategies
* Assess documentation and lineage needs
* Identify reusable transformation patterns
* Estimate development effort and complexity

The agent should proactively suggest:

* Dimensional modeling approaches (star schemas, slowly changing dimensions)
* dbt best practices (model organization, naming conventions, materialization)
* Testing strategies (data quality tests, freshness checks)
* Documentation patterns (dbt docs, data dictionary)
* Macro patterns for reusable SQL
* Performance optimization approaches
* Incremental model strategies
* Lineage and exposure documentation

Early-stage research outputs should always be documented and stored in a dedicated project structure.

Recommended folders:

/research
/research/data-models
/research/business-requirements
/research/technical-design
/research/testing-strategy
/research/notes

Research documents should include:

* Data model designs and dimensional schemas
* Transformation requirements and logic
* Testing strategies and data quality criteria
* dbt best practices decisions
* Performance considerations
* Documentation and lineage strategy
* Cost analysis and optimization opportunities
* Useful links and references
* Rejected approaches and why they were rejected

---

## Project Structure

* .gitignore              — Git ignore for dbt
* dbt_project.yml         — dbt project configuration
* models/                 — dbt transformation models
  * staging/              — Source-conformed staging models
  * intermediate/         — Intermediate transformation models
  * marts/                — Analytics marts (facts and dimensions)
* macros/                 — Reusable SQL macros
* tests/                  — Custom dbt tests
* seeds/                  — Reference data and seed files
* snapshots/              — Slowly changing dimension snapshots
* analysis/               — Ad-hoc analysis queries
* src/                    — Operational source code
* skills/                 — Reusable automation and workflows (Info: intellectual property. Never track them and push them to GitHub)
* prompts/                — Reusable prompts (Info: intellectual property. Never track them and push them to GitHub)
* docs/                   — Documentation (beyond dbt docs)
* infra/                  — Infrastructure scripts (SQL DDL + COPY scripts for Redshift; Terraform if needed)
* scripts/                — Operational scripts (Info: intellectual property. Never track them and push them to GitHub)
* venv/                   — Python virtual environment

---

## Engineering Principles

* Prefer modular and reusable architectures
* Prioritize observability and monitoring (data quality, lineage, performance)
* Design for scalability and maintainability
* Separate staging, intermediate, and analytics layers
* Favor ELT patterns and loosely coupled transformations
* Prefer dimensional modeling for analytics (star schemas)
* Keep transformation logic clear and documented
* Optimize for analyst productivity and self-service
* Use cloud-native services pragmatically
* Document architectural trade-offs clearly

---

## Skill Design Principles

The agent should continuously identify repetitive workflows,
manual validation steps, duplicated logic, and opportunities
for reusable automation.

The goal is to improve long-term analytics engineering productivity,
reduce unnecessary manual work, and increase deterministic behavior.

General principles:

* Prefer deterministic SQL and dbt logic over repeated manual analysis
* Continuously identify repeatable transformation patterns that should become macros
* Avoid duplicate logic across models (use intermediate models or macros)
* Prefer modular and composable dbt models
* Reuse shared macros and packages
* Include validation and testing for all transformations
* Minimize unnecessary recomputation and incremental logic
* Separate transformation generation logic from data quality validation
* Avoid unsafe automatic transformations without explicit testing
* Suggest workflow optimizations when repeated patterns are detected
* Prefer practical and production-oriented solutions over theoretical abstraction

The agent should periodically review existing dbt models and workflows for:

* Redundant transformation logic
* Missing or incomplete tests
* Opportunities for incremental model optimization
* Macro extraction opportunities
* Reusability improvements
* Performance optimizations
* Simpler transformation alternatives
* Better documentation and lineage

The agent should prioritize maintainability,
clarity, modularity, and operational simplicity.
