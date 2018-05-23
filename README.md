# NEX Python Environment Installer

This is a fire-and-forget installer for NEX Python environment.

It is idempotent and can be rerun as many times as required.

The solution has been verified to work on CentOS 7, Amazon Linux, Ubuntu and OSX.

The script installs OS-level dependencies, if required, (gcc, git 2.x, make, etc),
launching installs with `sudo` if not root.

The rest of the solution only affects home directory:
* Installs PyEnv into ~/.pyenv
* Installs Python `$PYTHON_VERSION` (3.6.4 at the time of writing this)
* Installs Python dependencies in a virtual environment `nex`

## How To Install

Run `curl -Ls https://raw.githubusercontent.com/Traiana/nex-env/master/install.sh | bash`

**NOTE:** This will ask you to `sudo` to install OS packages, if you're not root.

Everything else, however, will be installed into your local dir.

The installer supports two options:
* `--prereqs-only` that only installs prerequisites that may require SU privileges:

  `curl -Ls https://raw.githubusercontent.com/Traiana/nex-env/master/install.sh | bash -s -- --prereqs-only`
* `--env-only` that assumes that all prerequisites are already installed and only local user environment is needed

  `curl -Ls https://raw.githubusercontent.com/Traiana/nex-env/master/install.sh | bash -s -- --env-only`

## How To Use

Activate your environment by running:

`source ~/.pyenv/versions/nex/bin/activate`

Your shell is not configured to use NEX Virtual Environment and ready to run proxy and other scripts.
