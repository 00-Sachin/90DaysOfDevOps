### Use git reset --soft to go back one commit — what happens to the changes?
> git reset --soft  is used to undo the commit and place the changes into the staging area. NOTE: It does not change or modify/undo the actual change; it only undoes the commit from version control to stagging area

### Re-commit, then use git reset --mixed to go back one commit — what happens now?
> When using it with --mixed, it did the same task: undo commits, not actual changes, but here it did not take the change to the staging area insted it takes to untracked, infact other files stored in the staged area will also be trafnfed into untracked area

### Re-commit, then use git reset --hard to go back one commit — what happens this time?
> This one is amazing; it not only undoes the commits but also deletes the commit from the record; the commit will not be in staging nor untracked; it is removed permanently. NOTE: it will also not undo the actual changes
