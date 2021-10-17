import debugpy  # type: ignore[import]


def pytest_runtestloop() -> None:
    debugpy.listen(5678)
    debugpy.wait_for_client()
