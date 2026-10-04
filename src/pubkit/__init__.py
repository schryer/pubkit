"""pubkit: the testing setup every package shares.

A pytest plugin (`pubkit.plugin`, registered through the `pytest11` entry
point) and a small command, `pubkit`, that keeps each repository's copies of
the shared files in step with the version it pins.
"""

from importlib.metadata import PackageNotFoundError, version

try:
    __version__ = version("pubkit")
except PackageNotFoundError:  # running from a source tree
    __version__ = "0.0.0"
