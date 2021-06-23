# Prompt Two
> Company: Dunder Mifflin Technologies
>
> Version control platform(s): They currently use Gerrit, out-of-the-box Git, Subversion, and Team Foundation Server.
>
> Customer requests:
>
> * Help us modernize our practices: Dunder Mifflin is worried they are falling behind their industry. They have lots of legacy software and development patterns that were created 20 years ago. They have found it incredibly difficult to change any aspect of their SDLC because of their infrastructure, processes, and long-tenured team members who are resistant to change.

Getting all of the team members on the same page is much more important (and difficult) than any technical obstacles that may stand in the way. There are as many reasons developers may resist agile, and there is unlikely one size fits all solution to get them all on board. Change is hard. It's scary and uncomfortable, and it could threaten our sense of home. I think we should take the time to listen to them and respond to them with empathy. By simply asking a few questions and avoiding any judgmental statements, we can guide them to making the decision on their own.

> * Help us release more often: Dunder Mifflin releases software four times a year. They are shipping largely web-based applications. They want to increase more frequently, but they are unsure of the best first steps. What areas would you explore with the customer to help them move this goal forward?

Automated testing is key. Manually testing software is tedious and prone to error. It takes a long time to get it right. I would start by automating tests for the parts of the code they wish to update most frequently, and gradually build a comprehensive testing suite for the entire codebase. I would also recommend they break the changes up into much smaller portions. Making smaller changes makes it easier to diagnose problems after deployment. Eventually, I would want to automate their CI/CD process completely so pushing to production is as simple as merging branches. But you have to approach the situation with a crawl, walk, run strategy.

> * Commit/merge/deploy permissions: Dunder Mifflin has expressed concern about moving away from Gerrit. They have asked how they can control repository access, merging, and deployment permissions within GitHub, and what aspects of their desired security setup can be enforced programmatically.

GitHub offers a rich set of features for protecting repositories and branches. Under the repository settings, you can choose granular permissions for each user or team. Branches can be protected from being modified by unauthorized users or without a pull request. Unfortunately, to the best of my knowledge, these settings cannot be enforced at the organizational level. However, using the GitHub API, you can create a web service that responds to webhooks and automatically imposes restrictions, as we've seen in the second half of this technical assessment.
