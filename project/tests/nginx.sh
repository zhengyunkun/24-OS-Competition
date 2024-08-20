#!/bin/bash

# Set test parameters
CONCURRENCY=20
REQUESTS=3000000

# Define container runtimes and Nginx container image
CONTAINERS=("vkernel-runtime" "runsc" "no-runtime")
IMAGE="nginx:latest"

# Define the results directory
RESULTS_DIR="../results/nginx"

# Create results directory if it doesn't exist
mkdir -p $RESULTS_DIR

# Define the test function
run_test() {
    # Assign the first argument passed to the function to the local variable runtime
    local runtime=$1

    # Generate a unique container name
    local container_name="nginx-${runtime}-$(date +%s)"

    echo "Running test with $runtime runtime..."

    # Start the Nginx container with the appropriate runtime and measure the time taken
    if [ "$runtime" == "no-runtime" ]; then
        # If runtime is no-runtime, do not use the --runtime parameter
        docker run -d --name $container_name -p 8080:80 $IMAGE
    else
        # Otherwise, use the specified --runtime parameter
        docker run -d --name $container_name --runtime=$runtime -p 8080:80 $IMAGE
    fi

    # Wait for Nginx to start
    sleep 10

    # Run the stress test and output results in real-time while saving to a file
    { time ab -n $REQUESTS -c $CONCURRENCY http://localhost:8080/; } 2>&1 | tee $RESULTS_DIR/ab_$runtime.txt

    # Stop and remove the Nginx container
    docker stop $container_name
    docker rm $container_name

    echo "Test results with $runtime runtime saved to $RESULTS_DIR/ab_$runtime.txt"
}

# Run tests
for runtime in "${CONTAINERS[@]}"; do
    run_test $runtime
done

echo "All tests completed."
