#!/bin/bash
set -e

# Create a temp env name
ENV_NAME=tmp_codecarbon_env_$$

# 1. Create temporary conda environment
conda create -y -n $ENV_NAME python=3.10 > /dev/null
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate $ENV_NAME

# 2. Install dependencies
conda env update -n $ENV_NAME -f environment.yml
pip install codecarbon

# 3. Create wrapper script
cat > run_with_emissions.py <<EOF
from codecarbon import EmissionsTracker
tracker = EmissionsTracker(output_file="emissions.csv")
tracker.start()
exec(open("main.py").read())
tracker.stop()
EOF

# 4. Run and log output
python run_with_emissions.py > codecarbon.log 2>&1

# 5. Show emissions
echo -e "\nCarbon Emissions Report:"
tail -n 1 emissions.csv | awk -F, '{ printf "- CO₂ emitted: %.4f kg\n- Energy consumed: %.4f kWh\n- Region: %s - %s\n", $6, $14, $16, $17 }'

# 6. Parse for fallback messages
echo -e "\n⚠️ Notes:"
grep -E "WARNING" codecarbon.log | sed -E 's/^\[[^]]+\] */- /' || echo "None"

# 7. Cleanup
conda deactivate
conda remove -y -n $ENV_NAME --all > /dev/null
rm -f run_with_emissions.py codecarbon.log
