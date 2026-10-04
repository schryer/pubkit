Feature: Keeping a repository's shared files in step
  `pubkit init` writes the shared files; `pubkit sync --check` fails when a
  managed one differs from the installed pubkit's, so copies cannot drift.

  Scenario: init writes managed and seeded files for a Rust package
    Given an empty repository
    When I run pubkit "init" "--kind=rust" "--bin=demo"
    Then it succeeds
    And the repository has "pubkit.mk", "rust-toolchain.toml", "tests/requirements-pubkit.txt", "tests/requirements.txt", "tests/pytest.ini", "Makefile", ".github/workflows/ci.yml"
    And "Makefile" contains "DEMO_BIN_DIR"
    And "tests/requirements-pubkit.txt" pins this pubkit's wheel

  Scenario: init keeps the repository's own files
    Given an empty repository
    And the file "tests/pytest.ini" reads "[pytest]"
    When I run pubkit "init" "--kind=python"
    Then it succeeds
    And it prints "kept     tests/pytest.ini"
    And "tests/pytest.ini" contains "[pytest]"

  Scenario: A freshly initialised repository is in step
    Given a repository initialised as "python"
    When I run pubkit "sync" "--check"
    Then it succeeds
    And it prints "in step with pubkit"

  Scenario: An edited managed file fails the check, and sync restores it
    Given a repository initialised as "rust"
    And the file "pubkit.mk" reads "edited"
    When I run pubkit "sync" "--check"
    Then it fails
    And stderr mentions "pubkit.mk differs"
    When I run pubkit "sync"
    Then it succeeds
    And it prints "updated  pubkit.mk"
    When I run pubkit "sync" "--check"
    Then it succeeds

  Scenario: Seeded files are the repository's to change
    Given a repository initialised as "rust"
    And the file "Makefile" reads "include pubkit.mk"
    When I run pubkit "sync" "--check"
    Then it succeeds

  Scenario: A lock pinning another pubkit fails the check
    Given a repository initialised as "python"
    And the file "tests/requirements.lock" reads "pubkit @ https://example.org/download/v0.0.0/pubkit-0.0.0-py3-none-any.whl"
    When I run pubkit "sync" "--check"
    Then it fails
    And stderr mentions "does not pin pubkit"

  Scenario: sync outside an initialised repository says what to do
    Given an empty repository
    When I run pubkit "sync" "--check"
    Then it fails
    And stderr mentions "run `pubkit init"

  Scenario: lock pins every file the index publishes, so it installs on any platform
    Given an empty repository
    And a package "demo" 1.0 whose index lists files hashed "aaaa" and "bbbb"
    And the file "tests/requirements.txt" reads "demo==1.0"
    When I run pubkit "lock"
    Then it succeeds
    And "tests/requirements.lock" pins "demo==1.0" with the hashes "aaaa", "bbbb" and the resolved file's
