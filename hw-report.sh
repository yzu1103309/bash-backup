parts=()

# =========================
# CPU
# =========================
CPU=$(lscpu 2>/dev/null | awk -F: '/Model name/ {
    x=$2
    gsub(/^[ \t]+|[ \t]+$/, "", x)
    gsub(/\(R\)|\(TM\)/, "", x)
    gsub(/CPU @ .*/, "", x)
    gsub(/Intel Core /, "", x)
    gsub(/AMD Ryzen /, "Ryzen ", x)
    gsub(/  +/, " ", x)
    print x
    exit
}')

[ -n "$CPU" ] && parts+=("CPU: $CPU")


# =========================
# RAM
# =========================
if command -v dmidecode >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then

    RAM=$(dmidecode -t memory 2>/dev/null | awk '
    /^Memory Device$/ {
        size=""
        unit=""
        type=""
        speed=""
    }

    /^[[:space:]]*Size:/ && $2 != "No" && $2 != "Unknown" {
        size=$2
        unit=$3
    }

    /^[[:space:]]*Type:/ && $2 != "Unknown" {
        type=$2
    }

    /^[[:space:]]*Configured Memory Speed:/ &&
    $4 != "Unknown" &&
    $4 != "0" {
        speed=$4
    }

    /^$/ && size != "" {
        key=size "|" unit "|" type "|" speed
        count[key]++
        size=""
    }

    END {
        first=1
        total_gb=0

        for (k in count) {
            split(k,a,"|")

            if (!first)
                printf " + "

            if (a[4] != "")
                printf "%s%s %s-%s×%d", a[1], a[2], a[3], a[4], count[k]
            else
                printf "%s%s %s×%d", a[1], a[2], a[3], count[k]

            if (a[2] == "GB")
                total_gb += a[1] * count[k]

            first=0
        }

        if (total_gb > 0)
            printf " (%dGB)", total_gb
    }')

else
    RAM=$(free -b 2>/dev/null | awk '/Mem:/ {
        gb=int(($2/1024/1024/1024)+0.5)
        if (gb > 0)
            printf "%dGB", gb
    }')
fi

[ -n "$RAM" ] && parts+=("RAM: $RAM")


# =========================
# Storage
# =========================
STORAGE=$(lsblk -bdn -o NAME,TYPE,SIZE,ROTA,TRAN 2>/dev/null | awk '

function advertised(bytes, gb) {
    gb = bytes / 1000000000

    if (gb < 140)   return "120GB"
    if (gb < 220)   return "200GB"
    if (gb < 300)   return "250GB"
    if (gb < 400)   return "320GB"
    if (gb < 600)   return "500GB"
    if (gb < 850)   return "750GB"
    if (gb < 1300)  return "1TB"
    if (gb < 1700)  return "1.5TB"
    if (gb < 2500)  return "2TB"
    if (gb < 3500)  return "3TB"
    if (gb < 4500)  return "4TB"
    if (gb < 5500)  return "5TB"
    if (gb < 7000)  return "6TB"
    if (gb < 9000)  return "8TB"
    if (gb < 11000) return "10TB"
    if (gb < 13000) return "12TB"
    if (gb < 15000) return "14TB"
    if (gb < 17000) return "16TB"
    if (gb < 19000) return "18TB"
    if (gb < 22000) return "20TB"
    if (gb < 26000) return "24TB"

    return sprintf("%.0fTB", gb / 1000)
}

$2 == "disk" {
    name=$1
    size=advertised($3)
    rota=$4
    tran=$5

    if (name ~ /^nvme/)
        kind="M.2/NVMe SSD"
    else if (rota == 1)
        kind=(tran=="sata" ? "SATA HDD" : "HDD")
    else
        kind=(tran=="sata" ? "SATA SSD" : "SSD")

    key=kind "|" size
    count[key]++
}

END {
    first=1

    for (k in count) {
        split(k,a,"|")

        if (!first)
            printf " + "

        printf "%s %s×%d", a[1], a[2], count[k]

        first=0
    }
}')

[ -n "$STORAGE" ] && parts+=("Storage: $STORAGE")


# =========================
# GPU
# =========================
if command -v nvidia-smi >/dev/null 2>&1; then

    GPU=$(nvidia-smi \
        --query-gpu=name,memory.total \
        --format=csv,noheader,nounits 2>/dev/null | awk -F, '
    {
        name=$1
        mem=$2

        gsub(/^[ \t]+|[ \t]+$/, "", name)
        gsub(/^[ \t]+|[ \t]+$/, "", mem)

        gb=int((mem/1024)+0.5)

        if (NR>1)
            printf " + "

        printf "%s %dGB", name, gb
    }')

elif command -v lspci >/dev/null 2>&1; then

    GPU=$(lspci 2>/dev/null | awk -F': ' '
    /VGA compatible controller|3D controller/ {
        print $2
        exit
    }')

fi

[ -n "$GPU" ] && parts+=("GPU: $GPU")


# =========================
# Motherboard
# =========================
VENDOR=$(cat /sys/class/dmi/id/board_vendor 2>/dev/null)
BOARD=$(cat /sys/class/dmi/id/board_name 2>/dev/null)

if [ -n "$BOARD" ] &&
   [ "$BOARD" != "Default string" ] &&
   [ "$BOARD" != "To be filled by O.E.M." ] &&
   [ "$BOARD" != "Unknown" ]; then

    MB="$BOARD"

    case "$BOARD" in
        *"$VENDOR"*)
            ;;
        *)
            [ -n "$VENDOR" ] && MB="$VENDOR $BOARD"
            ;;
    esac

    parts+=("Motherboard: $MB")
fi


# =========================
# PSU
# =========================
if command -v dmidecode >/dev/null 2>&1 && [ "$(id -u)" -eq 0 ]; then

    PSU=$(dmidecode -t 39 2>/dev/null | awk -F: '

    /^[[:space:]]*Name:/ {
        x=$2
        gsub(/^[ \t]+|[ \t]+$/, "", x)

        if (x != "" &&
            x != "Unknown" &&
            x != "To Be Filled By O.E.M.")
            name=x
    }

    /^[[:space:]]*Max Power Capacity:/ {
        x=$2
        gsub(/^[ \t]+|[ \t]+$/, "", x)

        if (x != "" &&
            x != "Unknown")
            power=x
    }

    END {
        if (name != "" && power != "")
            print name " " power
        else if (name != "")
            print name
        else if (power != "")
            print power
    }')

    [ -n "$PSU" ] && parts+=("PSU: $PSU")
fi


# =========================
# Output
# =========================
printf "%s\n" "${parts[@]}"
