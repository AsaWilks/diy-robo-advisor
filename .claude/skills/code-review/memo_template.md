# Code QA Review Memo Template

Use this template when producing a formal RAND-style code review memo. Fill in all sections. Required modifications must be addressed before signoff.

---

## Header Information

| Field | Value |
|---|---|
| **Code Reviewer** | [Name of person performing the review] |
| **Project Name** | [NAME] |
| **Project PI(s)** | [NAME(S)] |
| **Project Code QA Contact(s)** | [The project member(s) fielding questions on the code, typically the code's author(s)] |
| **Project RQAM** | [The division Research Quality Assurance Manager for the project] |
| **Special Code QA Instructions** | [E.g., special instructions for high visibility products] |
| **Time Allocated for Code QA Review** | [Can be a range or blank if flexible] |
| **How AI Tools Were Used to Create the Code** | [Briefly describe or write N/A] |

---

## Description of Code and Data

Describe:
- Location of code, data, and documentation
- Technical details (language(s) and platform(s))
- How the project code and data are organized
- Other relevant technical details
- Names of products that code outputs will contribute to

*[Code reviewer should confirm accuracy or adjust]*

---

## Time Spent on Code QA Review

[Hours or days charged]

---

## Approval and Sign Off

When satisfied that the code is high quality and reproducible, write:

> "Yes, the code is high quality and reproducible. I approve and sign off on the code. I attest that I have sufficient expertise to conduct this code review."

| Field | Value |
|---|---|
| **Sign off statement** | [Statement] |
| **Name** | [Code reviewer name] |
| **Date** | [Date of sign off] |

---

## What Was Reviewed and Not Reviewed

- Describe specific aspects of the project that were **in scope** for the review (e.g., reviewed and executed R code, reviewed output tables)
- List anything **out of scope** (e.g., input datasets prepared by an external data provider)

---

## How Was the Review Conducted

- Describe the specific activities performed during the review, including attempts at reproducing results
- Describe iterations with code authors and what was fixed

---

## Special Considerations and Challenges

- Discuss anything that prevented a thorough code review (e.g., data that could not be accessed, insufficient time)

---

## Overall Impression

Comment on:
- Code quality (organization, documentation)
- Reproducibility by a programmer at a future date
- Anything else relevant

---

## Areas for Improvement

### Required Modifications

Showstoppers that must be fixed (e.g., code that produces errors, output that doesn't match results tables).

| # | Required Modification | Programmer Comments | Reviewer Approval |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |

### Recommended Modifications

Suggested changes that are not essential but are good practices.

| # | Recommended Modification | Programmer Comments | Reviewer Approval |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |
