import subprocess
from dotenv import load_dotenv

load_dotenv()
dbt_command = ["dbt", "debug"]

try:
    subprocess.run(dbt_command, check=True, cwd="./")
    print("dbt command executed successfully!")
except subprocess.CalledProcessError as e:
    print(f"dbt command failed: {e}")
except FileNotFoundError:
    print("dbt executable not found. Make sure dbt is installed and in your PATH.")
