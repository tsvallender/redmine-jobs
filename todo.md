- Add a job model
    - Start/end date
    - External project ID (one-to-one relationship)
    - Name
    - Client (project ID)
    - Description
    - Job ID? (this is in Amigo)
    - Status (pending acceptance etc.)
    - Total time (budget per activity type?)
    - List of associated trackers
- Add association between time log entries and jobs
- Add UI for jobs
    - CRUD stuff
    - Set up default associations

- Separate plugin:
    - Whenever time log is updated, fire this at Everhour
    - Back the other way?

- What about meetings etc?

- Examples:
    - Developer logs time for ticket #123
    - Doesn't explicitly choose a job
    - Logged as development time
    - If ticket is in retainer tracker the time is logged against the retainer job
    - If ticket is in support tracker the time is logged against the support job
    - If ticket is anywhere else, it is logged against the active project

    - Product manager logs time for ticket #123
    - Doesn't explicitly choose a job
    - Logged as refinement time
    -
