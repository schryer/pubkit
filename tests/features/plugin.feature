Feature: The plugin every suite loads
  A suite that installs pubkit gets the binary resolver, the command runner,
  the per-scenario context, the common steps, and its feature tags as
  markers, without writing any of them.

  Scenario: The common steps judge a command's result
    Given a suite whose feature reads:
      """
      Feature: echo
        Scenario: success
          When I run echo "hello"
          Then it succeeds
          And it prints "hello"
          And the exit code is 0

        Scenario: failure
          When I run false
          Then it fails
          And stdout is empty
      """
    When the suite runs
    Then 2 scenarios pass

  Scenario: A common step that does not hold fails the scenario, showing the run
    Given a suite whose feature reads:
      """
      Feature: echo
        Scenario: wrong text
          When I run echo "hello"
          Then it prints "goodbye"
      """
    When the suite runs
    Then 1 scenario fails
    And the report shows "stdout: 'hello\\n'"

  Scenario: Cleanups run in reverse, even when the scenario fails
    Given a suite whose feature reads:
      """
      Feature: cleanup
        Scenario: fails after registering cleanups
          Given cleanups "first" and "second"
          Then it fails anyway
      """
    When the suite runs
    Then 1 scenario fails
    And the cleanups ran as "second,first"

  Scenario: Feature tags are markers, so strict markers and selection work
    Given a suite whose feature reads:
      """
      Feature: tagged
        @browser
        Scenario: slow
          When I run true
          Then it succeeds

        Scenario: fast
          When I run true
          Then it succeeds
      """
    When the suite runs with "-m" "not browser"
    Then 1 scenario passes
    And 1 scenario is deselected

  Scenario: The program under test comes from its BIN_DIR variable
    Given a suite whose feature reads:
      """
      Feature: binary
        Scenario: resolve
          When I run the "tool" binary
          Then it succeeds
          And it prints "tool ran"
      """
    And a "tool" program in a directory named by TOOL_BIN_DIR
    When the suite runs
    Then 1 scenario passes

  Scenario: An unset BIN_DIR variable fails clearly instead of testing PATH
    Given a suite whose feature reads:
      """
      Feature: binary
        Scenario: resolve
          When I run the "tool" binary
          Then it succeeds
      """
    When the suite runs
    Then 1 scenario fails
    And the report shows "TOOL_BIN_DIR is not set"
