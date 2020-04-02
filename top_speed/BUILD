# Group tests to run in different jobs
test_suite(
    name = "unit-tests",
    tests = [
        "//top_speed/src/test/java/com/fintechstudios/ff_sf2020/top_speed:unit-tests"
    ],
)

test_suite(
    name = "int-tests",
    tests = [
         "//top_speed/src/test/java/com/fintechstudios/ff_sf2020/top_speed:int-tests"
    ],
)

test_suite(
    name = "lint",
    tests = [
        "//top_speed/src/main/java/com/fintechstudios/ff_sf2020/top_speed:lint",
        "//top_speed/src/test/java/com/fintechstudios/ff_sf2020/top_speed:lint"
    ],
)

# Main application alias
alias(
    name = "top_speed",
    actual = "//top_speed/src/main/java/com/fintechstudios/ff_sf2020/top_speed",
)
