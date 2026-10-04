Feature: The reusable workflows parse as GitHub reads them
  pubkit's own CI runs only python-ci.yml, so a malformed rust-ci.yml would
  first fail in someone else's repository. Every workflow it ships is parsed
  here instead.

  Scenario Outline: A reusable workflow declares well-formed inputs
    When I parse the workflow "<workflow>"
    Then it is called with workflow_call
    And every input has only a type, a default, a description or required
    And every job the workflow runs uses only its declared inputs

    Examples:
      | workflow      |
      | rust-ci.yml   |
      | python-ci.yml |
