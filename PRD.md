1. Product Summary

Media Sorter is a specialized, computationally driven spreadsheet application built in Flutter. While it mimics the interface of a standard tabular data editor, its primary function is to act as a constraint-based scheduling and sequencing engine for media assets.

Instead of relying on basic alphabetical or chronological sorting, Media Sorter uses algorithmic solvers to organize rows (representing individual media files like videos, images, or grouped media) based on complex relational and spatial rules. It is designed to find the optimal sequence of media assets that respects strict positioning requirements while simultaneously maximizing separation between designated conflicting items.
2. The Algorithmic Sorting Engine

The core value proposition of Media Sorter is its "Find better sort" engine. The application treats the sorting process as a combination of a Constraint Satisfaction Problem (CSP) and an optimization algorithm.

    Dependencies (Strict Constraints): The algorithm enforces exact positional rules between media assets. For example, it guarantees that Row A appears exactly 3 rows after Row B, or 9 rows before Row C.

    Sprawl (Optimization Constraints): The algorithm simultaneously attempts to maximize the distance between specific items. If two items share a sprawl constraint, the engine pushes them as far apart in the final sequence as possible without breaking the strict dependency rules.

    Continuous Optimization: Users can toggle features like "Find best sort" to continuously compute better permutations, and "Apply best sort automatically" to update the spreadsheet in real-time as the algorithm discovers superior sequences.

3. Data Model & Column Typology

To feed the sorting engine, columns in the Media Sorter spreadsheet are not just data containers; they have explicitly defined behavioral types that dictate how the data is processed:

    Names: The primary identifier or title of the media row.

    Dependencies: Cells containing the strict relational constraints (e.g., +3 Row B, -9 Row C).

    Sprawl: Cells defining which items this specific row must be pushed away from.

    Attributes: Metadata tags. (Note: Rows can inherit attributes from other rows to create grouped media behaviors).

    FilePath & URLs: The physical location or web address of the media asset, bridging the gap between the metadata representation and the actual file.

4. Contextual Analysis & Diagnostics View

Because constraint-based sorting can easily result in logical conflicts (e.g., Row A must be before B, B before C, and C before A), the application features a robust side-panel dedicated to real-time analysis and error logging.

    Mentions Tree: A relational graph tool. When a user selects a row, this tree displays all other rows that mention it. This includes rows that reference it in a positional dependency, or rows that mention it in their "Attributes" column to inherit its traits and constraints.

    DistPairs (Distance Pairs): A diagnostic view that lists all pairs of rows currently subjected to Sprawl constraints. This allows users to monitor exactly which items the algorithm is actively trying to separate.

    Warnings & Errors: Flags impossible constraint loops or conflicting dependencies so the user can manually intervene.

5. User Interface & Architecture

The presentation layer is optimized for heavy data entry and real-time feedback:

    High-Performance 2D Grid: Built utilizing bidirectional scrolling (two_dimensional_scrollables), ensuring smooth navigation even with large datasets.

    Seamless Editing: Features inline cell editing with keyboard shortcuts (like Shift+Enter to save and move) and perfectly matched text bounds to prevent visual layout shifts when toggling between reading and editing.

    Dynamic Column Management: Users can contextualize data on the fly by right-clicking column headers to assign or reassign Column Types.

    Multi-Workbook Support: Users can seamlessly search, create, and swap between different sheets via an autocomplete interface in the side panel.




























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