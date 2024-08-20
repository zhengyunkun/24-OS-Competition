#!/bin/bash

# Set test parameters
PASSWORD_COUNT=10370

# Define container runtimes and pwgen container image
CONTAINERS=("vkernel-runtime" "runsc" "no-runtime")
IMAGE="backplane/pwgen"

# Define the results directory
RESULTS_DIR="../results/pwgen"

# Create results directory if it doesn't exist
mkdir -p $RESULTS_DIR

# Define the test function
run_test() {
    # Assign the first argument passed to the function to the local variable runtime
    local runtime=$1

    # Generate a unique container name
    local container_name="pwgen-${runtime}-$(date +%s)"

    echo "Running test with $runtime runtime..."

    # Start the pwgen container with the appropriate runtime and measure the time taken
    if [ "$runtime" == "no-runtime" ]; then
        # If runtime is no-runtime, do not use the --runtime parameter
        docker run -d --name $container_name $IMAGE $PASSWORD_COUNT
    else
        # Otherwise, use the specified --runtime parameter
        docker run -d --name $container_name --runtime=$runtime $IMAGE $PASSWORD_COUNT
    fi

    # Wait for the pwgen container to start
    sleep 10

    # Run the test and output results in real-time while saving to a file
    { time docker exec $container_name pwgen $PASSWORD_COUNT; } 2>&1 | tee $RESULTS_DIR/time_$runtime.txt

    # Stop and remove the pwgen container
    docker stop $container_name
    docker rm $container_name

    echo "Test results saved to $RESULTS_DIR/time_$runtime.txt"
}

# Run tests
for runtime in "${CONTAINERS[@]}"; do
    run_test $runtime
done

echo "All tests completed."
