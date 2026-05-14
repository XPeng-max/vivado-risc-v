#!/bin/bash

# Build script for all nWays x nMSHRs configurations with multiple prefetchers
# This script builds 27 configurations: 
# - 9 baseline configs: {2,4,8} x {2,4,8}
# - 9 stream prefetcher configs: {2,4,8} x {2,4,8}
# - 9 stride prefetcher configs: {2,4,8} x {2,4,8}
# - (Optional: 9 nextline prefetcher configs for full evaluation)

BOARD=genesys2
CURRENT_DATE=$(date +%m%d)
CONFIGS=(
    "Rocket64x1w4m8"
    "AlectoIntegratedPrefetchRocket64x1w4m8"
)
# CONFIGS=(

# #     # Baseline configurations without prefetcher - nMSHRs=4 only
# #     # "Rocket64x1w2m2"
# #     # "Rocket64x1w2m4"
# #     # "Rocket64x1w2m8"
# #     # "Rocket64x1w4m2"
# #     # "Rocket64x1w4m4"
#     "Rocket64x1w4m8"
# #     # "Rocket64x1w8m2"
# #     # "Rocket64x1w8m4"
# #     # "Rocket64x1w8m8"
    
# #     # Stream Prefetcher configurations - nMSHRs=4 only
# #     # "StreamPrefetchRocket64x1w2m2"
# #     # "StreamPrefetchRocket64x1w2m4"
# #     # "StreamPrefetchRocket64x1w2m8"
# #     # "StreamPrefetchRocket64x1w4m2"
# #     # "StreamPrefetchRocket64x1w4m4"
#     "StreamPrefetchRocket64x1w4m8"
# #     # "StreamPrefetchRocket64x1w8m2"
# #     # "StreamPrefetchRocket64x1w8m4"
# #     # "StreamPrefetchRocket64x1w8m8"
    
# #     # Stride Prefetcher configurations (commented out)
# #     # "StridePrefetchRocket64x1w2m2"
# #     # "StridePrefetchRocket64x1w2m4"
# #     # "StridePrefetchRocket64x1w2m8"
# #     # "StridePrefetchRocket64x1w4m2"
# #     # "StridePrefetchRocket64x1w4m4"
#     "StridePrefetchRocket64x1w4m8"
# #     # "StridePrefetchRocket64x1w8m2"
# #     # "StridePrefetchRocket64x1w8m4"
# #     # "StridePrefetchRocket64x1w8m8"
    
# #     # NextLine Prefetcher configurations (commented out)
# #     # "NextLinePrefetchRocket64x1w2m2"
# #     # "NextLinePrefetchRocket64x1w2m4"
# #     # "NextLinePrefetchRocket64x1w2m8"
# #     # "NextLinePrefetchRocket64x1w4m2"
# #     # "NextLinePrefetchRocket64x1w4m4"
#     "NextLinePrefetchRocket64x1w4m8"
# #     # "NextLinePrefetchRocket64x1w8m2"
# #     # "NextLinePrefetchRocket64x1w8m4"
# #     # "NextLinePrefetchRocket64x1w8m8"

# #     # CPLX Prefetcher configurations (commented out)
#     "CPLXPrefetchRocket64x1w4m8"

# #     # Integrated Prefetcher configurations (commented out)
# #     # "StrideStreamCPLXAlectoIntegratedPrefetchMediumBoomV3Config"
# #     # "StrideStreamCPLXIntegratedPrefetchMediumBoomV3Config"
# #     # "StrideStreamNextLineIntegratedPrefetchMediumBoomV3Config"
# #     # "StrideStreamNextLineAlectoIntegratedPrefetchMediumBoomV3Config"
# #     # "StrideNextLineCPLXIntegratedPrefetchMediumBoomV3Config"
# #     # "StrideNextLineCPLXAlectoIntegratedPrefetchMediumBoomV3Config"
# #     # "StreamNextLineCPLXIntegratedPrefetchMediumBoomV3Config"
# #     # "StreamNextLineCPLXAlectoIntegratedPrefetchMediumBoomV3Config"
#     "AlectoIntegratedPrefetchRocket64x1w4m8"
#     "IntegratedPrefetchRocket64x1w4m8"
# #     # "StrideCPLXIntegratedPrefetchRocket64x1w4m8"
# #     # "StrideCPLXAlectoIntegratedPrefetchRocket64x1w4m8"
# #     # "CPLXNextLineIntegratedPrefetchRocket64x1w4m8"
# #     # "CPLXStreamIntegratedPrefetchRocket64x1w4m8"
# #     # "NextLineStrideIntegratedPrefetchRocket64x1w4m8"
# #     # "NextLineStreamIntegratedPrefetchRocket64x1w4m8"
# #     # "CPLXNextLineAlectoIntegratedPrefetchRocket64x1w4m8"
# #     # "CPLXStreamAlectoIntegratedPrefetchRocket64x1w4m8"
# #     # "NextLineStrideAlectoIntegratedPrefetchRocket64x1w4m8"
# #     # "NextLineStreamAlectoIntegratedPrefetchRocket64x1w4m8"

# )
# Log file to record build status
LOG_FILE="build_all_$(date +%Y%m%d_%H%M%S).log"

echo "==================================" | tee -a "$LOG_FILE"
echo "Starting batch build process" | tee -a "$LOG_FILE"
echo "Board: $BOARD" | tee -a "$LOG_FILE"
echo "Total configurations: ${#CONFIGS[@]}" | tee -a "$LOG_FILE"
echo "Start time: $(date)" | tee -a "$LOG_FILE"
echo "==================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Track successful and failed builds
SUCCESS_COUNT=0
FAIL_COUNT=0
FAILED_CONFIGS=()

# Build each configuration sequentially
for CONFIG in "${CONFIGS[@]}"; do
    echo "==================================" | tee -a "$LOG_FILE"
    echo "Building configuration: $CONFIG" | tee -a "$LOG_FILE"
    echo "Start time: $(date)" | tee -a "$LOG_FILE"
    echo "==================================" | tee -a "$LOG_FILE"
    
    # Backup previous workspace if it exists
    if [ -d "./workspace/$CONFIG" ]; then
        mv "./workspace/$CONFIG" "./workspace/${CONFIG}_old_${CURRENT_DATE}"
    fi
    
    # Run make command
    if make CONFIG=$CONFIG BOARD=$BOARD bitstream 2>&1 | tee -a "$LOG_FILE"; then
        echo "" | tee -a "$LOG_FILE"
        echo "✓ SUCCESS: $CONFIG completed successfully" | tee -a "$LOG_FILE"
        echo "End time: $(date)" | tee -a "$LOG_FILE"
        ((SUCCESS_COUNT++))
    else
        echo "" | tee -a "$LOG_FILE"
        echo "✗ FAILED: $CONFIG build failed" | tee -a "$LOG_FILE"
        echo "End time: $(date)" | tee -a "$LOG_FILE"
        ((FAIL_COUNT++))
        FAILED_CONFIGS+=("$CONFIG")
    fi
    
    echo "" | tee -a "$LOG_FILE"
done

# Print summary
echo "==================================" | tee -a "$LOG_FILE"
echo "Build Summary" | tee -a "$LOG_FILE"
echo "==================================" | tee -a "$LOG_FILE"
echo "Total configurations: ${#CONFIGS[@]}" | tee -a "$LOG_FILE"
echo "Successful builds: $SUCCESS_COUNT" | tee -a "$LOG_FILE"
echo "Failed builds: $FAIL_COUNT" | tee -a "$LOG_FILE"

if [ $FAIL_COUNT -gt 0 ]; then
    echo "" | tee -a "$LOG_FILE"
    echo "Failed configurations:" | tee -a "$LOG_FILE"
    for FAILED_CONFIG in "${FAILED_CONFIGS[@]}"; do
        echo "  - $FAILED_CONFIG" | tee -a "$LOG_FILE"
    done
fi

echo "" | tee -a "$LOG_FILE"
echo "End time: $(date)" | tee -a "$LOG_FILE"
echo "Log saved to: $LOG_FILE" | tee -a "$LOG_FILE"
echo "==================================" | tee -a "$LOG_FILE"

# Exit with error code if any builds failed
if [ $FAIL_COUNT -gt 0 ]; then
    exit 1
else
    exit 0
fi
