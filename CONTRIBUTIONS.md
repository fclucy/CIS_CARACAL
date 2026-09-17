### Contributing to CIS_CARACAL

Thank you for contributing to CIS_CARACAL.

This repository intentionally uses a simple two-branch workflow:

* `main` — stable and reviewed code.
* `dev` — the working/development branch.

No additional long-lived branches are needed for this project.

### Development Workflow

All changes must be made on the `dev` branch.

Before making changes, switch to `dev` and make sure it is up to date:

```bash
git checkout dev
git pull origin dev
```

Make your changes, test them locally, and commit them to `dev`:

```bash
git add .
git commit -m "Describe the change"
git push origin dev
```

When the changes are ready, open a **Pull Request** on GitHub from:

```text
dev -> main
```

Changes should never be pushed directly to `main`.

### Pull Requests

Pull requests should:

* Clearly describe what was changed.
* Explain any relevant testing that was performed.
* Be reasonably focused on the change being made.
* Be reviewed before being merged into `main`.

Once a pull request has been reviewed and is ready, it may be merged into `main`.

### Branch Policy

The repository intentionally maintains only two branches:

```text
main
dev
```

Do not create additional permanent development branches.

Temporary local branches may be used if necessary for experimentation, but completed work should ultimately be brought into `dev` before being submitted for a pull request to `main`.

### Important

`main` is protected by GitHub repository settings. Direct pushes to `main` are not permitted.

If you are unsure about the workflow, use:

```text
dev -> make changes -> test -> push dev -> Pull Request -> main
```
