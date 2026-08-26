# Approved Visual Source Storage Policy

Every newly approved image must be durably stored in both locations before it
is treated as a completed asset handoff:

1. the exact source file under `docs/assets/approved/` in this repository;
2. the exact original binary attached to its Notion Asset Library record.

The Asset Library record must retain the approval decision, SHA-256,
dimensions, alpha/background result, source provenance, and intended runtime
consumer. A Drive copy may be used for transport or backup, but it does not
replace the Notion binary attachment.

If either required durable copy is missing, label the asset registration as
blocked and do not mark it `IMPLEMENTATION_READY` or `RUNTIME_VERIFIED`.
Runtime integration additionally requires the relevant technical asset checks
(including a real alpha channel when transparent background is required).
