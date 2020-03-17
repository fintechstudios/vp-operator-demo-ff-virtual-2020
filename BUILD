# Root test suites for all modules

test_suite(
    name = "unit-tests",
    tests = [
        "//top_speed:unit-tests",
    ],
)

test_suite(
    name = "int-tests",
    tests = [
        "//top_speed:int-tests",
    ],
)

test_suite(
    name = "lint",
    tests = [
        "//top_speed:lint",
    ],
)

test_suite(
    name = "all-tests",
    tests = [
        "//:int-tests",
        "//:lint",
        "//:unit-tests",
    ],
)
