# Competitor Intel

A Lightning Web Component that shows your track record against one competitor: win rate, bookings won and lost, average margin on wins compared with losses, why you lose to them, and the most recent head-to-head deals.

- **On an Opportunity** it profiles the opportunity's **Incumbent**. On an open opportunity it also compares the pursuit's Estimated Margin with its Margin Floor.
- **On an Account** it profiles the account itself, but only when the account is a competitor (its Account Role includes "Competitor").

"Head to head" means deals closed in the last three years where the competitor was the incumbent or was recorded as the one you lost to. A loss counts against a competitor only when Lost To is that competitor or is blank.

## What's included

| Metadata | Purpose |
| --- | --- |
| `lwc/competitorIntel` | The component, available on Opportunity and Account record pages |
| `classes/CompetitorIntelController` | Apex that adds up the head-to-head history (`with sharing`, `USER_MODE` queries) |
| `classes/CompetitorIntelControllerTest` | Unit tests |
| `Account.Account_Role__c` | Multi-select picklist: Customer, Supplier, Partner, Competitor |
| `Account.Is_Competitor__c` | Formula: Account Role includes Competitor |
| `Opportunity.Incumbent__c` | Lookup to a competitor Account |
| `Opportunity.Lost_To__c` | Lookup to the competitor Account that won the award |
| `Opportunity.Loss_Reason__c` | Picklist: Price, Technical, Past Performance, Incumbent Advantage, Schedule, No Bid, Other |
| `Opportunity.Estimated_Margin__c` | Percent |
| `Opportunity.Contract_Type__c` | Picklist using the `Contract_Type` global value set |
| `Opportunity.Margin_Floor__c` | Formula: Cost Plus 7%, Time & Materials 10%, Fixed Price (or blank) 12% |
| `permissionsets/Competitor_Intel_Access` | Apex class access and field permissions |

## Install

```sh
sf project deploy start --target-org <alias> --test-level RunSpecifiedTests --tests CompetitorIntelControllerTest
sf org assign permset --name Competitor_Intel_Access --target-org <alias>
```

Then, in Lightning App Builder, add **Competitor Intel** to an Opportunity or Account record page and activate the page.

To try it in a scratch org:

```sh
sf org create scratch --definition-file config/project-scratch-def.json --alias competitor-intel
sf project deploy start --target-org competitor-intel
sf org assign permset --name Competitor_Intel_Access --target-org competitor-intel
```

## Data the component needs

1. Mark competitor accounts by adding **Competitor** to their Account Role.
2. On opportunities, set the **Incumbent**. On closed lost deals, also set **Lost To** and **Loss Reason**.
3. Fill in **Estimated Margin** and **Expected Contract Type** so the margin comparison has data.

## If your org already has fields with these names

The field API names are generic. If your org already has any of them (for example `Loss_Reason__c`), deploying will overwrite that field's definition. Check before you deploy, or rename the fields here and in `CompetitorIntelController.cls`.
