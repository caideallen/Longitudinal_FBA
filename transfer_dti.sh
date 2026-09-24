#!/bin/bash
# transfer_dti.sh
# Usage: ./transfer_dti.sh

ID_FILE="with_v2.txt"
SRC_BASE="../../storage/Aging/Aging_In_ASD/Dicom_Master"
DEST_HOST="supercomputer"
DEST_BASE="/scratch/myname/40plus_Dicoms"

if [[ ! -f "$ID_FILE" ]]; then
    echo "ID file not found: $ID_FILE"
    exit 1
fi

while IFS= read -r ID || [[ -n "$ID" ]]; do
    # skip blank lines
    [[ -z "$ID" ]] && continue

    for n in 03 04 05 06; do
        SRC="${SRC_BASE}/sub-${ID}/ses-${n}/DTI32*"

        # check if anything matches the glob before trying to copy
        if compgen -G "$SRC" > /dev/null; then
            DEST_DIR="${DEST_HOST}:${DEST_BASE}/sub-${ID}/ses-${n}"
            echo ">> Copying sub-${ID} ses-${n}"

            # make sure remote destination directory exists
            ssh "${DEST_HOST}" "mkdir -p ${DEST_BASE}/sub-${ID}/ses-${n}"

            scp -r $SRC "${DEST_DIR}/"
        else
            echo "-- Skipping sub-${ID} ses-${n} (no DTI32* found)"
        fi
    done
done < "$ID_FILE"

echo "Done."
