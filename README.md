Multiple services app for daily life


Spreadsheet feature:







Productivity feature:

I want a Flutter app where I define tasks and the time proportion to allocate for them, and that will tell me what to do now and notifies me when to go to which task. It would take into account the moments when the screen is open or not and sync between my devices. I can define the minimum time for each task (if a task that is 0.001% has a 30 minutes minimum time, then it will happen every 100,000 minutes of work). On the computer, when the user stops working on the scheduled task but wants to keep the screen on, the user can press a simple keyboard shortcut to indicate so, and again to indicate that he/she gets back to the task.
Every 20 minutes of work on a screen, it tells the user to look away and 20 seconds later to get back to work. Every 1 hour, it tells him/her to take a pause, then 5 minutes later the phone rings to indicate to get back to work. Every 2 hours, another pause of 15 minutes is set.
 
V1 (Core Loop): Local storage only. Add tasks, set proportions, calculate the next task, run a timer, send a local notification when the time is up.

V2 (Context): App lifecycle tracking (pausing/adjusting when the screen is closed or the app is backgrounded).

V3 (Cloud): Cross-device synchronization.