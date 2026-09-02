Workflow Used -  GitHub Flow with branch protection and hotfix discipline.
how developers contribute changes - Since it’s a small project with 5 developers a suitable branching strategy will be 3 branches (main, develop, hotfix). The main branch should be protected and no merges will be allowed without PR and Code Review. 
how production-ready code is protected - By using branch protection rules in main branch and code reviews
how emergency fixes are handled - A seperate hotfix branch is created vias which developers can make changes for emergency stuff.
the trade-offs of your approach - Need to think of more ways for branch protection and code related reviews and maybe roles and authorization related checks as to who will be responsible for the maintenance.
