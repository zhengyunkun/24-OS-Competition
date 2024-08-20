#!/bin/bash

# Define container runtimes and ubuntu container image
CONTAINERS=("vkernel-runtime" "runsc" "no-runtime")
IMAGE="ubuntu:latest"

# Define the results directory
RESULTS_DIR="../results/startup"

# Create results directory if it doesn't exist
mkdir -p $RESULTS_DIR

# Define the test function
run_test() {
    # Assign the first argument passed to the function to the local variable runtime
    local runtime=$1

    # Generate a unique container name
    local container_name="ubuntu-${runtime}-$(date +%s)"

    echo "Running test with $runtime runtime..."

    # Measure the time taken to start the ubuntu container
    if [ "$runtime" == "no-runtime" ]; then
        # If runtime is no-runtime, do not use the --runtime parameter
        { time docker run -d --name $container_name $IMAGE /bin/sh -c "sleep 5"; } 2>&1 | tee $RESULTS_DIR/startup_$runtime.txt
    else
        # Otherwise, use the specified --runtime parameter
        { time docker run -d --name $container_name --runtime=$runtime $IMAGE /bin/sh -c "sleep 5"; } 2>&1 | tee $RESULTS_DIR/startup_$runtime.txt
    fi

    # Stop and remove the ubuntu container
    docker stop $container_name
    docker rm $container_name

    echo "Test results saved to $RESULTS_DIR/startup_$runtime.txt"
}

# Run tests
for runtime in "${CONTAINERS[@]}"; do
    run_test $runtime
done

echo "All tests completed."