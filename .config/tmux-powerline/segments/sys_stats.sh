#!/usr/bin/env bash

run_segment() {

	# ---- CPU (%) ----
	if [[ "$OSTYPE" == "darwin"* ]]; then
		cpu=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
	else
		cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
		cpu=$(printf "%.0f" "$cpu")
	fi

	# ---- 内存 已用/总量 ----
	if [[ "$OSTYPE" == "darwin"* ]]; then
		mem=$(vm_stat | awk '
		/Pages active/ {a=$3}
		/Pages wired/ {w=$4}
		/Pages occupied by compressor/ {c=$5}
		/Pages free/ {f=$3}
		END {
			gsub("\\.","",a); gsub("\\.","",w); gsub("\\.","",c); gsub("\\.","",f);
			used=(a+w+c)*4096/1024/1024/1024;
			total=(a+w+c+f)*4096/1024/1024/1024;
			printf("%.1fG/%.1fG", used, total)
		}')
	else
		read total used <<<$(free -m | awk '/Mem:/ {print $2, $3}')
		mem=$(printf "%.1fG/%.1fG" "$(echo "$used/1024" | bc -l)" "$(echo "$total/1024" | bc -l)")
	fi

	# ---- GPU (nvidia-smi) ----
	gpu_util="--"
	gpu_mem="--/--"

	if command -v nvidia-smi >/dev/null 2>&1; then
		read util mem_used mem_total <<<$(nvidia-smi \
			--query-gpu=utilization.gpu,memory.used,memory.total \
			--format=csv,noheader,nounits | head -n1)

		gpu_util="${util}%"
		gpu_mem="${mem_used}/${mem_total}M"
	fi

	# ---- 图标（需要 Nerd Font）----
	cpu_icon=""
	gpu_icon=""
	mem_icon=""

	# ---- 输出 ----
	echo "${cpu_icon} ${cpu}% | ${gpu_icon} ${gpu_util} ${gpu_mem} | ${mem_icon} ${mem}"
}
