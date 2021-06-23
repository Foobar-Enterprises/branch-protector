# Prompt One
> Company: Acme computers
>
> Version control platform(s): Many GitHub Enterprise instances installed throughout the company by different teams. Acme Computers is trying to standardize on GitHub Enterprise and consolidate their GitHub usage onto a single instance. The company has many instances of other Git hosting solutions installed as well. Some are fully supported applications. Other instances are on machines under people's desks.
>
> Customer requests:
>
> * Shrink large repository: Acme wants GitHub to help them shrink the large repository to a more manageable size that is performant for common Git operations. The large repo is a project that is high visibility with an aggressive roadmap. They request that we help them within the month. It's a large, monolithic repository.

If the repository has a long history, I would suggest that the developers perform a shallow clone. This will save them time and disk space, and the usual push and pull commands will still work. However, this doesn't answer the question posed here - how to shrink the large repository.

The most common reason I've seen for a git repository to be excessively large is storing blobs - binary large objects. This often happens when development teams store things JAR dependencies in their repository. The problem with this is that once a large file has been committed to the main branch, it doesn't go away. Simply deleting the file and pushing a new commit does not remove that file from the repository. It's merely hidden from view in the recent commit, and it can be retrieved by checking out an old commit. If a 40MB JAR file is added to the repository and updated every month, your repository will grow by 480MB each year. These files are not going anywhere.

There are solutions to this problem, but they come with a catch. Removing these files will require rewriting the old commits. This will cause your repository to be incompatible with other people's copies. The commit hashes will change not only for the commit that introduced the file, but all the subsequent commits as well, since commit hashes depend on the hash of the parent commit. This will cause a lot of confusion and headaches, and will significant ramifications for your auditing trail. This is not a decision to be made lightly.

Before proceeding, I would recommend making a backup of the original repository and submitting a change mangement ticket describing the change that will take place. You may also want to investigate automation that will prevent large blobs from being added in the future so we don't repeat our mistakes.

You could come up with your own solution using [git filter-branch](https://git-scm.com/docs/git-filter-branch), but there exists an excellent tool that will the legwork for you. I've used [BFG Repo Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) with success in the past to remove sensitive data that was leaked to a GitHub repository, and it also works well for removing large files. Removing all files greater than 1MB is as simple as running `bfg --strip-blobs-bigger-than 1M  my-repo.git`.

> * Consolidate instances: Acme wants you to tell them the best way to move all the other teams, using GitHub Enterprise or other Git solutions, onto their consolidated GitHub Enterprise instance. They have asked you to give them five or six bullet points about how you would approach that initiative, both technically and culturally.

From a technical standpoint, I would recommend automating the entire process to be sure no mistakes are made. The script would have to create a mapping of users and permissions between the old repositories to the new ones.

The script would involve the following steps:
1. Make the original repository read-only to prevent developers from committing changes to the old repository after the migration has been performed.
1. Use the GitHub API to create a new empty repository and set all of the desired permissions, branch protections, etc.
1. Clone the repository to the new GitHub Enterprise installation.
1. If applicable, use APIs (BitBucket, GitHub, etc.) to copy meta data, such as pull requests and issues.
1. Once the migration has been completed, push a new commit to the old repository, replacing all of the contents with a message informing users of the migration and how to find their code in the new GitHub installation.

If any of the developers aren't familiar with GitHub, I would encourage the company to provide training so they can get the most out of their GitHub license. GitHub provides many advantages over vanilla git, so I would want to make sure everyone is aware of all the benefits available to them.

> * Migrate an SVN repo: The customer has one SVN repository that hasn't migrated over to a Git solution. They would like help moving this one large repository over. The team has a trunk based development pattern with this repository and is unfamiliar with Git.

Since the team isn't familiar with git, I would like to point out a couple key differences between git and SVN.

1. Git is decentralized. Your copy of a repository is a complete and fully functional repository, so you can feel free to commit as often as you'd like to avoid losing work. Access to the central GitHub server is not necessary.
1. Git stores commits in a [directed acyclic graph](https://en.wikipedia.org/wiki/Directed_acyclic_graph), whereas SVN commits are purely linear. This has some practical implications. For example, in git, you can branch from any commit.

The git project includes a special tool for working with SVN repositories. The `git svn` command will pull a copy of an SVN repository and convert it to a git repository. Not only can it be used for converting from SVN to git, but it can even be used to push changes back to the SVN repository. This is an optional feature, so it may not have come with your installation. On Debian systems, you can install it via `sudo apt install git-svn`.

Since SVN uses a centralized repository model, its history stores a unique username for each user. Because git is decentralized, it uniquely identifies user by email address instead. So when importing an SVN repository into git, we can provide a mapping between usernames to git identities using the `--authors-file` flag.

Once you've provided the authors mapping and cloned the repository, you can simply push this new repository to GitHub.

# Resources Used
1. https://rtyley.github.io/bfg-repo-cleaner/
1. [Version Control with Git, Second Edition by Jon Loeliger & Matthew McCullough](https://www.amazon.com/dp/1449316387/)
