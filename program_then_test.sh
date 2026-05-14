#!/bin/bash

# ========================================
# 变量定义
# ========================================
FPGA_HOST="debian@192.168.10.109"
FPGA_PASSWD="debian"
# CONFIGS=("AlectoIntegratedPrefetchRocket64x1w4m8")
CONFIGS=(

#     # Baseline configurations without prefetcher - nMSHRs=4 only
#     # "Rocket64x1w2m2"
#     # "Rocket64x1w2m4"
#     # "Rocket64x1w2m8"
#     # "Rocket64x1w4m2"
#     # "Rocket64x1w4m4"
    "Rocket64x1w4m8"
#     # "Rocket64x1w8m2"
#     # "Rocket64x1w8m4"
#     # "Rocket64x1w8m8"
    
#     # Stream Prefetcher configurations - nMSHRs=4 only
#     # "StreamPrefetchRocket64x1w2m2"
#     # "StreamPrefetchRocket64x1w2m4"
#     # "StreamPrefetchRocket64x1w2m8"
#     # "StreamPrefetchRocket64x1w4m2"
#     # "StreamPrefetchRocket64x1w4m4"
    "StreamPrefetchRocket64x1w4m8"
#     # "StreamPrefetchRocket64x1w8m2"
#     # "StreamPrefetchRocket64x1w8m4"
#     # "StreamPrefetchRocket64x1w8m8"
    
#     # Stride Prefetcher configurations (commented out)
#     # "StridePrefetchRocket64x1w2m2"
#     # "StridePrefetchRocket64x1w2m4"
#     # "StridePrefetchRocket64x1w2m8"
#     # "StridePrefetchRocket64x1w4m2"
#     # "StridePrefetchRocket64x1w4m4"
    "StridePrefetchRocket64x1w4m8"
#     # "StridePrefetchRocket64x1w8m2"
#     # "StridePrefetchRocket64x1w8m4"
#     # "StridePrefetchRocket64x1w8m8"
    
#     # NextLine Prefetcher configurations (commented out)
#     # "NextLinePrefetchRocket64x1w2m2"
#     # "NextLinePrefetchRocket64x1w2m4"
#     # "NextLinePrefetchRocket64x1w2m8"
#     # "NextLinePrefetchRocket64x1w4m2"
#     # "NextLinePrefetchRocket64x1w4m4"
    "NextLinePrefetchRocket64x1w4m8"
#     # "NextLinePrefetchRocket64x1w8m2"
#     # "NextLinePrefetchRocket64x1w8m4"
#     # "NextLinePrefetchRocket64x1w8m8"

#     # CPLX Prefetcher configurations (commented out)
    "CPLXPrefetchRocket64x1w4m8"

#     # Integrated Prefetcher configurations (commented out)
#     # "StrideStreamCPLXAlectoIntegratedPrefetchMediumBoomV3Config"
#     # "StrideStreamCPLXIntegratedPrefetchMediumBoomV3Config"
#     # "StrideStreamNextLineIntegratedPrefetchMediumBoomV3Config"
#     # "StrideStreamNextLineAlectoIntegratedPrefetchMediumBoomV3Config"
#     # "StrideNextLineCPLXIntegratedPrefetchMediumBoomV3Config"
#     # "StrideNextLineCPLXAlectoIntegratedPrefetchMediumBoomV3Config"
#     # "StreamNextLineCPLXIntegratedPrefetchMediumBoomV3Config"
#     # "StreamNextLineCPLXAlectoIntegratedPrefetchMediumBoomV3Config"
    "AlectoIntegratedPrefetchRocket64x1w4m8"
    "IntegratedPrefetchRocket64x1w4m8"
#     # "StrideCPLXIntegratedPrefetchRocket64x1w4m8"
#     # "StrideCPLXAlectoIntegratedPrefetchRocket64x1w4m8"
#     # "CPLXNextLineIntegratedPrefetchRocket64x1w4m8"
#     # "CPLXStreamIntegratedPrefetchRocket64x1w4m8"
#     # "NextLineStrideIntegratedPrefetchRocket64x1w4m8"
#     # "NextLineStreamIntegratedPrefetchRocket64x1w4m8"
#     # "CPLXNextLineAlectoIntegratedPrefetchRocket64x1w4m8"
#     # "CPLXStreamAlectoIntegratedPrefetchRocket64x1w4m8"
#     # "NextLineStrideAlectoIntegratedPrefetchRocket64x1w4m8"
#     # "NextLineStreamAlectoIntegratedPrefetchRocket64x1w4m8"

)
USER="pxk"
COMMIT_ID="fpgafix80_tlb32_73bb9984fb659b0fa12d15786df8f00b5a3ab23d"
PASSWD="mprc1818"
VIVADO_BAT_PATH="D:/Xilinx/Vivado/2023.2/bin/vivado.bat"
REMOTE_USER="xianhua"
REMOTE_HOST="192.168.200.30"

# ========================================
# 可选执行开关
# ========================================
RUN_SPEC_2006=0      # 1=执行SPEC CPU 2006运行与日志传输, 0=跳过
RUN_SPEC_2017=1      # 1=执行SPEC CPU 2017运行与日志传输, 0=跳过
DELETE_REMOTE_TCL=1  # 1=烧录后删除远程TCL脚本, 0=保留远程TCL脚本
SPEC_CPU_2006_SUB_TARGET=()  # 为空则执行all, 非空则按数组元素拼接为A,B,C
SPEC_CPU_2017_SUB_TARGET=()  # 为空则执行all, 非空则按数组元素拼接为A,B,C

# ========================================
# 日志文件设置
# ========================================
LOG_FILE="program_then_test_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================"
echo "脚本启动时间: $(date)"
echo "日志文件: $LOG_FILE"
echo "========================================"

# ========================================
# 主循环：遍历所有CONFIG
# ========================================
for CONFIG in "${CONFIGS[@]}"; do
    echo ""
    echo "========================================"
    echo "开始处理 CONFIG: $CONFIG"
    echo "时间: $(date)"
    echo "========================================"

    # 路径定义
    SRC_PATH="workspace/${CONFIG}/vivado-genesys2-riscv/genesys2-riscv.runs/impl_1/riscv_wrapper.bit"
    DST_DIR="C:/Users/Xianhua/Desktop/Bits_${USER}"
    DST_PATH="${DST_DIR}/${CONFIG}-${COMMIT_ID}.bit"

    # ----------------------------------------
    # 步骤1: 等待源文件生成
    # ----------------------------------------
    echo "[$CONFIG] 步骤1: 等待源文件生成..."
    SRC_WAIT_INTERVAL=600  # 10分钟
    SRC_MAX_RETRY=24       # 最多24次（4小时）
    SRC_RETRY=0
    while [ ! -f "$SRC_PATH" ]; do
        if [ $SRC_RETRY -ge $SRC_MAX_RETRY ]; then
            echo "[$CONFIG] 等待超时: 源文件始终不存在: $SRC_PATH"
            exit 1
        fi
        echo "[$CONFIG] 源文件不存在: $SRC_PATH，等待 $SRC_WAIT_INTERVAL 秒后重试（第$((SRC_RETRY+1))次）..."
        sleep $SRC_WAIT_INTERVAL
        SRC_RETRY=$((SRC_RETRY+1))
    done
    echo "[$CONFIG] 源文件已存在: $SRC_PATH"

    # ----------------------------------------
    # 步骤2: 传输bitstream到Windows主机
    # ----------------------------------------
    echo "[$CONFIG] 步骤2: 传输bitstream到Windows主机..."
    
    # 远程创建目标文件夹（Windows下用 powershell）
    sshpass -p "$PASSWD" ssh ${REMOTE_USER}@${REMOTE_HOST} "powershell -Command \"if (!(Test-Path -Path '$DST_DIR')) { New-Item -ItemType Directory -Path '$DST_DIR' }\""

    # 使用sshpass进行scp传输
    sshpass -p "$PASSWD" scp "$SRC_PATH" "${REMOTE_USER}@${REMOTE_HOST}:$DST_PATH"

    if [ $? -ne 0 ]; then
        echo "[$CONFIG] 文件传输失败"
        exit 1
    fi
    echo "[$CONFIG] 文件已成功传输到远程主机: $DST_PATH"

    # ----------------------------------------
    # 步骤3: 烧录FPGA
    # ----------------------------------------
    echo "[$CONFIG] 步骤3: 烧录FPGA..."
    
    # 生成临时tcl脚本
    TCL_LOCAL_PATH="/tmp/prog_fpga_${CONFIG}_${COMMIT_ID}.tcl"
    # 注意：Vivado TCL 支持正斜杠路径，无需转换
    cat > "$TCL_LOCAL_PATH" << EOF
# Vivado Hardware Manager TCL Script
# 烧录 bitstream: ${DST_PATH}

open_hw_manager
connect_hw_server
open_hw_target

# 获取第一个设备（假设只有一个FPGA连接）
set device [lindex [get_hw_devices] 0]
if {\$device eq ""} {
    puts "ERROR: No FPGA device found!"
    exit 1
}
current_hw_device \$device
refresh_hw_device -update_hw_probes false [current_hw_device]

# 设置bitstream文件路径
set_property PROGRAM.FILE {${DST_PATH}} [current_hw_device]

# 烧录
program_hw_devices [current_hw_device]

puts "Programming completed successfully!"
close_hw_manager
exit
EOF

    # 上传tcl脚本到远程主机
    TCL_REMOTE_PATH="C:/Users/Xianhua/Desktop/Bits_${USER}/prog_fpga_${CONFIG}_${COMMIT_ID}.tcl"
    sshpass -p "$PASSWD" scp "$TCL_LOCAL_PATH" "${REMOTE_USER}@${REMOTE_HOST}:$TCL_REMOTE_PATH"

    # 输出TCL脚本内容到日志
    echo "[$CONFIG] TCL脚本内容如下："
    echo "----------------------------------------"
    cat "$TCL_LOCAL_PATH"
    echo "----------------------------------------"

    # 远程执行vivado烧录
    sshpass -p "$PASSWD" ssh ${REMOTE_USER}@${REMOTE_HOST} "\"${VIVADO_BAT_PATH}\" -mode batch -source \"$TCL_REMOTE_PATH\""

    # 删除本地临时tcl脚本
    rm -f "$TCL_LOCAL_PATH"

    # 可选：删除远程tcl脚本
    if [ "$DELETE_REMOTE_TCL" -eq 1 ]; then
        echo "[$CONFIG] 删除远程TCL脚本: $TCL_REMOTE_PATH"
        sshpass -p "$PASSWD" ssh ${REMOTE_USER}@${REMOTE_HOST} "powershell -Command \"if (Test-Path -Path '$TCL_REMOTE_PATH') { Remove-Item -Path '$TCL_REMOTE_PATH' -Force }\""
    else
        echo "[$CONFIG] 保留远程TCL脚本: $TCL_REMOTE_PATH"
    fi

    echo "[$CONFIG] FPGA烧录完成"

    # ----------------------------------------
    # 步骤4: 等待FPGA主机上线并执行测试
    # ----------------------------------------
    if [ "$RUN_SPEC_2006" -eq 1 ] || [ "$RUN_SPEC_2017" -eq 1 ]; then
        echo "[$CONFIG] 步骤4: 等待FPGA主机上线并执行测试..."
        INTERVAL=300  # 5分钟
        MAX_RETRY=10 # 最多尝试10次（约50分钟）
        RETRY=0
        FPGA_ONLINE=0
        while [ $RETRY -lt $MAX_RETRY ]; do
            echo "[$CONFIG] 尝试第$((RETRY+1))次登录FPGA主机 $FPGA_HOST..."
            if sshpass -p "$FPGA_PASSWD" ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no $FPGA_HOST "echo 'FPGA主机已上线'"; then
                if [ "$RUN_SPEC_2006" -eq 1 ]; then
                    if [ ${#SPEC_CPU_2006_SUB_TARGET[@]} -gt 0 ]; then
                        SPEC_CPU_2006_TARGETS=$(IFS=,; echo "${SPEC_CPU_2006_SUB_TARGET[*]}")
                    else
                        SPEC_CPU_2006_TARGETS="all"
                    fi
                    echo "[$CONFIG][SPEC CPU 2006] FPGA主机已上线，开始执行run_all.sh..."
                    sshpass -p "$FPGA_PASSWD" ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no $FPGA_HOST "cd simpoint_ckpt06 && ./run_all.sh ${SPEC_CPU_2006_TARGETS}"
                    echo "[$CONFIG] SPEC CPU 2006 run_all.sh 执行完成。"
                else
                    echo "[$CONFIG][SPEC CPU 2006] 已关闭，跳过执行。"
                fi

                # echo "[$CONFIG] 开始执行SPEC2017脚本..."
                # sshpass -p "$FPGA_PASSWD" ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no $FPGA_HOST "cd spec2017_workspace/run_space && python ../src/main.py --all --tag ${USER}_${CONFIG}_${COMMIT_ID}"
                # echo "[$CONFIG] SPEC2017脚本执行完成。"

                if [ "$RUN_SPEC_2017" -eq 1 ]; then
                    if [ ${#SPEC_CPU_2017_SUB_TARGET[@]} -gt 0 ]; then
                        SPEC_CPU_2017_TARGETS=$(IFS=,; echo "${SPEC_CPU_2017_SUB_TARGET[*]}")
                    else
                        SPEC_CPU_2017_TARGETS="all"
                    fi
                    echo "[$CONFIG][SPEC CPU 2017] FPGA主机已上线，开始执行run_all.sh..."
                    sshpass -p "$FPGA_PASSWD" ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no $FPGA_HOST "cd simpoint_ckpt17 && ./run_all.sh ${SPEC_CPU_2017_TARGETS}"
                    echo "[$CONFIG] SPEC CPU 2017 run_all.sh 执行完成。"
                else
                    echo "[$CONFIG][SPEC CPU 2017] 已关闭，跳过执行。"
                fi

                FPGA_ONLINE=1
                break
            fi
            echo "[$CONFIG] FPGA主机未上线，$INTERVAL 秒后重试..."
            sleep $INTERVAL
            RETRY=$((RETRY+1))
        done

        if [ $FPGA_ONLINE -eq 0 ]; then
            echo "[$CONFIG] 超过最大重试次数，FPGA主机始终未上线。"
            exit 2
        fi
    else
        echo "[$CONFIG] 步骤4: RUN_SPEC_2006和RUN_SPEC_2017均为0，跳过FPGA在线等待与测试执行。"
    fi

    # ----------------------------------------
    # 步骤5: 传输测试结果日志到本地
    # ----------------------------------------
    if [ "$RUN_SPEC_2006" -eq 1 ] || [ "$RUN_SPEC_2017" -eq 1 ]; then
        echo "[$CONFIG] 步骤5: 传输测试结果日志到本地..."

        LOCAL_DATA_DIR="data/${CONFIG}_${COMMIT_ID}"
        if [ ! -d "$LOCAL_DATA_DIR" ]; then
            mkdir -p "$LOCAL_DATA_DIR"
            echo "[$CONFIG] 创建本地目录: $LOCAL_DATA_DIR"
        fi

        LOG_COPY_OK=1
        if [ "$RUN_SPEC_2006" -eq 1 ]; then
            if [ ${#SPEC_CPU_2006_SUB_TARGET[@]} -gt 0 ]; then
                for TARGET in "${SPEC_CPU_2006_SUB_TARGET[@]}"; do
                    sshpass -p "$FPGA_PASSWD" scp -o StrictHostKeyChecking=no "$FPGA_HOST:simpoint_ckpt06/${TARGET}_no_loop_predictor.log" "$LOCAL_DATA_DIR/" || LOG_COPY_OK=0
                done
            else
                sshpass -p "$FPGA_PASSWD" scp -o StrictHostKeyChecking=no "$FPGA_HOST:simpoint_ckpt06/*_no_loop_predictor.log" "$LOCAL_DATA_DIR/" || LOG_COPY_OK=0
            fi
        else
            echo "[$CONFIG][SPEC CPU 2006] 已关闭，跳过日志传输。"
        fi

        if [ "$RUN_SPEC_2017" -eq 1 ]; then
            if [ ${#SPEC_CPU_2017_SUB_TARGET[@]} -gt 0 ]; then
                for TARGET in "${SPEC_CPU_2017_SUB_TARGET[@]}"; do
                    sshpass -p "$FPGA_PASSWD" scp -o StrictHostKeyChecking=no "$FPGA_HOST:simpoint_ckpt17/${TARGET}_no_loop_predictor.log" "$LOCAL_DATA_DIR/" || LOG_COPY_OK=0
                done
            else
                sshpass -p "$FPGA_PASSWD" scp -o StrictHostKeyChecking=no "$FPGA_HOST:simpoint_ckpt17/*_no_loop_predictor.log" "$LOCAL_DATA_DIR/" || LOG_COPY_OK=0
            fi
        else
            echo "[$CONFIG][SPEC CPU 2017] 已关闭，跳过日志传输。"
        fi

        if [ "$LOG_COPY_OK" -eq 1 ]; then
            echo "[$CONFIG] 日志文件已成功传输到: $LOCAL_DATA_DIR"
        else
            echo "[$CONFIG] 部分或全部日志文件传输失败"
        fi
    else
        echo "[$CONFIG] 步骤5: RUN_SPEC_2006和RUN_SPEC_2017均为0，跳过日志传输。"
    fi

    # echo "[$CONFIG] 传输SPEC2017日志到本地..."
    # SPEC_LOG_REMOTE_DIR="spec2017_workspace/logs/${USER}_${CONFIG}_${COMMIT_ID}"
    # sshpass -p "$FPGA_PASSWD" scp -r -o StrictHostKeyChecking=no "$FPGA_HOST:${SPEC_LOG_REMOTE_DIR}/"* "$LOCAL_DATA_DIR/"
    # if [ $? -eq 0 ]; then
    #     echo "[$CONFIG] SPEC2017日志已成功传输到: $LOCAL_DATA_DIR"
    #     echo "[$CONFIG] 删除远程SPEC2017日志目录: $SPEC_LOG_REMOTE_DIR"
    #     sshpass -p "$FPGA_PASSWD" ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no $FPGA_HOST "rm -rf ${SPEC_LOG_REMOTE_DIR}"
    # else
    #     echo "[$CONFIG] SPEC2017日志传输失败，保留远程目录: $SPEC_LOG_REMOTE_DIR"
    # fi

    echo "[$CONFIG] 处理完成"
    echo "========================================"

done

echo ""
echo "========================================"
echo "所有CONFIG处理完成。"
echo "结束时间: $(date)"
echo "========================================"
