#!/bin/bash
# transfer_dti.sh
# Usage: ./transfer_dti.sh

ID_FILE="with_v2.txt"
SRC_BASE="../../storage/Aging/Aging_In_ASD/Dicom_Master"
DEST_HOST="supercomputer"
DEST_BASE="/scratch/myname/40plus_Dicoms"

# ControlMaster socket setup — lets all ssh/scp calls share ONE authenticated connection
CTRL_DIR="/.ssh/controlmasters"
mkdir -p "$CTRL_DIR"
CTRL_PATH="${CTRL_DIR}/%r@%h:%p"
SSH_OPTS=(-o ControlMaster=auto -o ControlPath="$CTRL_PATH" -o ControlPersist=10m)

if [[ ! -f "$ID_FILE" ]]; then
    echo "ID file not found: $ID_FILE"
    exit 1
fi

echo "Opening connection to ${DEST_HOST} (approve Duo now if prompted)..."
ssh "${SSH_OPTS[@]}" -fN "${DEST_HOST}"
if [[ $? -ne 0 ]]; then
    echo "Failed to establish master connection. Exiting."
    exit 1
fi
echo "Connected. Starting transfers..."

while IFS= read -r ID || [[ -n "$ID" ]]; do
    [[ -z "$ID" ]] && continue

    for n in 03 04 05 06; do
        SRC="${SRC_BASE}/sub-${ID}/ses-${n}/DTI32*"

        if compgen -G "$SRC" > /dev/null; then
            DEST_DIR="${DEST_HOST}:${DEST_BASE}/sub-${ID}/ses-${n}"
            echo ">> Copying sub-${ID} ses-${n}"

            ssh -n "${SSH_OPTS[@]}" "${DEST_HOST}" "mkdir -p ${DEST_BASE}/sub-${ID}/ses-${n}"
            scp -r "${SSH_OPTS[@]}" $SRC "${DEST_DIR}/" < /dev/null
        else
            echo "-- Skipping sub-${ID} ses-${n} (no DTI32* found)"
        fi
    done
done < "$ID_FILE"

echo "Done. Closing master connection..."
ssh "${SSH_OPTS[@]}" -O exit "${DEST_HOST}"
