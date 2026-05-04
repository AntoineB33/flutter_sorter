Title: Proportionate (Dynamic Task Scheduler)
Status: Draft
Target Platforms: iOS, Android (via Flutter)
1. Product Overview

Traditional task managers rely on fixed schedules or manual to-do lists. "Proportionate" is a dynamic scheduling app where users define a set of tasks, a target time allocation percentage for each, and a minimum execution block. The app monitors active work time and dynamically calculates which task the user should be doing right now to maintain their desired long-term proportions.
2. Core Concepts & Definitions

    Active Time: The total accumulated time the user has spent "working" (device screen is on/unlocked).

    Target Proportion: The desired percentage of Active Time allocated to a specific task (e.g., "Reading: 15%").

    Minimum Block: The smallest chunk of time a user is willing to spend on a task at once to avoid context-switching fatigue (e.g., "Reading: Minimum 30 minutes").

    Time Debt: The difference between how much time a task should have received by now versus how much it actually received.

3. The Core Loop (Algorithm)

    The app continuously tracks "Active Time" locally.

    In the background, the app calculates the "Time Debt" for all tasks: (Total Active Time * Target Proportion) - Actual Time Spent.

    When a task's Time Debt exceeds its defined "Minimum Block," it enters the queue.

    If no task is currently active, the app notifies the user to start the task with the highest Time Debt.

    When the user completes the Minimum Block, the Time Debt is reduced, and the app recalculates the next priority.

4. User Stories

    As a user, I want to create a task with a percentage and a minimum time requirement, so my schedule is dictated by proportion, not fixed hours.

    As a user, I want the app to only count time when my device screen is active, so I am not assigned tasks while I am sleeping or away.

    As a user, I want to be notified immediately when I need to switch tasks, so I don't have to constantly check the app.

    As a user, I want my active time and task data to sync seamlessly between my phone and tablet.

5. Out of Scope (v1)

    Web/Desktop support.

    Collaboration or sharing tasks with other users.

    Strict app-blocking capabilities (e.g., forcing the user off an app).