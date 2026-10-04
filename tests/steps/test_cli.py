"""Steps for the `pubkit` command, run as a user would, in a scratch
repository, through the plugin's own `run` fixture."""

from __future__ import annotations

import shutil
import sys
from pathlib import Path

import pytest
from pytest_bdd import given, parsers, scenarios, then, when

from pubkit import __version__

scenarios("cli.feature")


@pytest.fixture
def repo(tmp_path):
    root = tmp_path / "repo"
    root.mkdir()
    return root


def pubkit():
    """The `pubkit` installed beside the Python running this suite."""
    found = shutil.which("pubkit", path=str(Path(sys.executable).parent))
    assert found, "pubkit is not installed in this environment; run `make venv`"
    return found


@given("an empty repository")
def empty(repo):
    pass


@given(parsers.parse('a repository initialised as "{kind}"'))
def initialised(repo, run, kind):
    assert run(pubkit(), "init", f"--kind={kind}", cwd=repo).code == 0


@given(parsers.parse('the file "{path}" reads "{text}"'))
def file_reads(repo, path, text):
    target = repo / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text + "\n")


@when(parsers.re(r'I run pubkit (?P<args>(?:"[^"]*" ?)+)'), target_fixture="result")
def run_pubkit(repo, run, args):
    return run(pubkit(), *args.strip().strip('"').split('" "'), cwd=repo)


@then(parsers.parse("the repository has {paths}"))
def has(repo, paths):
    for path in paths.split(", "):
        assert (repo / path.strip('"')).is_file(), path


@then(parsers.parse('"{path}" contains "{text}"'))
def contains(repo, path, text):
    assert text in (repo / path).read_text()


@then(parsers.parse('"{path}" pins this pubkit\'s wheel'))
def pins_wheel(repo, path):
    assert f"/download/v{__version__}/pubkit-{__version__}-py3-none-any.whl" in (
        repo / path).read_text()
